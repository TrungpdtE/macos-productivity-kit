#!/usr/bin/env bash
set -euo pipefail

KIT_NAME="macos-productivity-kit"
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

  workflow_name="$(feature_workflow_name "$feature_dir")"
  printf '%s/%s.workflow\n' "$SERVICES_DIR" "$workflow_name"
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

  printf 'File already exists: %s\n' "$path"
  printf 'Overwrite it? [y/N] '
  IFS= read -r answer
  case "$answer" in
    y|Y|yes|YES) return 0 ;;
    *) return 1 ;;
  esac
}
