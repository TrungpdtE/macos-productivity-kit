#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

info "No bundled Shortcuts are installed by default."
info "Place .shortcut files in shortcuts/ and import them manually on supported macOS versions."
