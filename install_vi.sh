#!/usr/bin/env bash
set -euo pipefail

export MPK_LANG=vi
exec "$(dirname "${BASH_SOURCE[0]}")/install.sh" "$@"
