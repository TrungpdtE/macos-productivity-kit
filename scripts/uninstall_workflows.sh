#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"
source "$(dirname "${BASH_SOURCE[0]}")/i18n.sh"

uninstall_feature_workflow() {
  local feature_dir="$1"
  local id workflow_path

  id="$(feature_id "$feature_dir")"
  workflow_path="$(workflow_path_for_feature "$feature_dir")"

  if [ -d "$workflow_path" ]; then
    rm -rf "$workflow_path"
    info "Removed $(feature_name "$feature_dir")"
  else
    info "Not installed: $(feature_name "$feature_dir")"
  fi

  forget_installed_feature "$id"
}

if [ "${1:-}" ]; then
  uninstall_feature_workflow "$1"
else
  discover_features | while IFS= read -r feature_dir; do
    uninstall_feature_workflow "$feature_dir"
  done
fi
