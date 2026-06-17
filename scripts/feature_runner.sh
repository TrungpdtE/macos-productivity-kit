#!/usr/bin/env bash
set -euo pipefail

usage() {
  printf 'Usage: %s install|uninstall FEATURE_DIR\n' "$(basename "$0")" >&2
  exit 1
}

[ "$#" -eq 2 ] || usage

action="$1"
feature_dir="$2"
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

case "$action" in
  install)
    "$script_dir/install_workflows.sh" "$feature_dir"
    ;;
  uninstall)
    "$script_dir/uninstall_workflows.sh" "$feature_dir"
    ;;
  *)
    usage
    ;;
esac
