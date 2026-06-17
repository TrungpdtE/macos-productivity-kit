#!/usr/bin/env bash
set -euo pipefail

KIT_NAME="macos-productivity-kit"
KIT_BUNDLE_PREFIX="MPK"
KIT_BUNDLE_IDENTIFIER_PREFIX="com.macos-productivity-kit"
KIT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FEATURES_DIR="$KIT_ROOT/features"
STATE_DIR="${HOME}/.local/share/${KIT_NAME}"
STATE_FILE="$STATE_DIR/installed_features.txt"
SERVICES_DIR="${HOME}/Library/Services"

die() {
  printf '%s: %s\n' "$KIT_NAME" "$*" >&2
  exit 1
}

info() {
  printf '%s\n' "$*"
}

ensure_dir() {
  mkdir -p "$1"
}

json_get() {
  local file="$1"
  local key="$2"

  plutil -extract "$key" raw -o - "$file" 2>/dev/null || true
}

feature_id() {
  json_get "$1/feature.json" "id"
}

feature_name() {
  json_get "$1/feature.json" "name"
}

feature_category() {
  json_get "$1/feature.json" "category"
}

feature_workflow_name() {
  json_get "$1/feature.json" "workflow_name"
}

feature_script() {
  json_get "$1/feature.json" "script"
}

feature_accepts() {
  json_get "$1/feature.json" "accepts"
}

feature_input_mode() {
  json_get "$1/feature.json" "input_mode"
}

workflow_bundle_display_name() {
  local feature_dir="$1"

  if [ "${MPK_LANG:-en}" = "vi" ] && declare -F workflow_bundle_display_name_i18n >/dev/null 2>&1; then
    workflow_bundle_display_name_i18n "$feature_dir"
  else
    feature_workflow_name "$feature_dir"
  fi
}

workflow_bundle_identifier() {
  local feature_dir="$1"

  printf '%s.%s\n' "$KIT_BUNDLE_IDENTIFIER_PREFIX" "$(feature_id "$feature_dir")"
}

workflow_bundle_name() {
  local feature_dir="$1"

  printf '%s - %s\n' "$KIT_BUNDLE_PREFIX" "$(workflow_bundle_display_name "$feature_dir")"
}

discover_features() {
  find "$FEATURES_DIR" -mindepth 2 -maxdepth 2 -name feature.json -print |
    while IFS= read -r manifest; do
      dirname "$manifest"
    done |
    sort
}

record_installed_feature() {
  local id="$1"

  ensure_dir "$STATE_DIR"
  touch "$STATE_FILE"
  if ! grep -Fqx "$id" "$STATE_FILE"; then
    printf '%s\n' "$id" >>"$STATE_FILE"
  fi
}

forget_installed_feature() {
  local id="$1"
  local tmp

  [ -f "$STATE_FILE" ] || return 0
  tmp="$(mktemp)"
  grep -Fvx "$id" "$STATE_FILE" >"$tmp" || true
  mv "$tmp" "$STATE_FILE"
}

is_installed_feature() {
  local id="$1"

  [ -f "$STATE_FILE" ] && grep -Fqx "$id" "$STATE_FILE"
}

workflow_path_for_feature() {
  local feature_dir="$1"
  local workflow_name

  workflow_name="$(workflow_bundle_name "$feature_dir")"
  printf '%s/%s.workflow\n' "$SERVICES_DIR" "$workflow_name"
}

workflow_bundle_paths_for_feature() {
  local feature_dir="$1"
  local expected_id path bundle_id

  expected_id="$(workflow_bundle_identifier "$feature_dir")"
  find "$SERVICES_DIR" -mindepth 1 -maxdepth 1 -type d -name '*.workflow' -print0 2>/dev/null |
    while IFS= read -r -d '' path; do
      bundle_id="$(plutil -extract CFBundleIdentifier raw -o - "$path/Contents/Info.plist" 2>/dev/null || true)"
      [ "$bundle_id" = "$expected_id" ] && printf '%s\n' "$path"
    done
}

remove_workflow_bundles_for_feature() {
  local feature_dir="$1"
  local path

  while IFS= read -r path; do
    [ -n "$path" ] || continue
    rm -rf "$path"
  done < <(workflow_bundle_paths_for_feature "$feature_dir")
}

workflow_path_is_owned() {
  local path="$1" bundle_id

  [ -d "$path" ] || return 1
  bundle_id="$(plutil -extract CFBundleIdentifier raw -o - "$path/Contents/Info.plist" 2>/dev/null || true)"
  [ "${bundle_id#${KIT_BUNDLE_IDENTIFIER_PREFIX}.}" != "$bundle_id" ]
}

confirm_overwrite() {
  local path="$1"
  local answer

  if [ ! -e "$path" ]; then
    return 0
  fi

  if [ "${MPK_FORCE_OVERWRITE:-0}" = "1" ]; then
    return 0
  fi

  if workflow_path_is_owned "$path"; then
    return 0
  fi

  if [ "${MPK_OVERWRITE_DECISION:-}" = "yes" ]; then
    return 0
  fi

  if [ "${MPK_OVERWRITE_DECISION:-}" = "no" ]; then
    return 1
  fi

  printf 'File already exists: %s\n' "$path"
  printf 'Overwrite existing workflows for this install? [y/N] '
  IFS= read -r answer
  case "$answer" in
    y|Y|yes|YES)
      MPK_OVERWRITE_DECISION="yes"
      return 0
      ;;
    *)
      MPK_OVERWRITE_DECISION="no"
      return 1
      ;;
  esac
}
