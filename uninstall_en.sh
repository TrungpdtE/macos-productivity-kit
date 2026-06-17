#!/usr/bin/env bash
set -euo pipefail

export MPK_LANG=en
exec "$(dirname "${BASH_SOURCE[0]}")/uninstall.sh" "$@"
