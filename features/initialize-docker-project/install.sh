#!/usr/bin/env bash
set -euo pipefail

feature_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"$feature_dir/../../scripts/feature_runner.sh" install "$feature_dir"
