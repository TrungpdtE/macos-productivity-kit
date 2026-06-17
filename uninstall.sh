#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/scripts/utils.sh"

print_header() {
  clear 2>/dev/null || true
  cat <<'EOF'
====================================
 macOS Productivity Kit Uninstaller
====================================

Select installed features to remove

EOF
}

ALL_FEATURES=()
while IFS= read -r feature_dir; do
  ALL_FEATURES+=("$feature_dir")
done < <(discover_features)
FEATURE_DIRS=()
for feature_dir in "${ALL_FEATURES[@]}"; do
  if is_installed_feature "$(feature_id "$feature_dir")"; then
    FEATURE_DIRS+=("$feature_dir")
  fi
done

if [ "${#FEATURE_DIRS[@]}" -eq 0 ]; then
  info "No installed features recorded."
  exit 0
fi

SELECTED=()
for _ in "${FEATURE_DIRS[@]}"; do
  SELECTED+=("0")
done
CURSOR=0

toggle_cursor() {
  local index="$CURSOR"

  if [ "$index" -eq "${#FEATURE_DIRS[@]}" ]; then
    for i in "${!SELECTED[@]}"; do
      SELECTED[$i]="1"
    done
    return 0
  fi

  if [ "${SELECTED[$index]}" = "1" ]; then
    SELECTED[$index]="0"
  else
    SELECTED[$index]="1"
  fi
}

draw_menu() {
  local index=0 marker pointer

  print_header
  for feature_dir in "${FEATURE_DIRS[@]}"; do
    if [ "$index" -eq "$CURSOR" ]; then
      pointer=">"
    else
      pointer=" "
    fi
    if [ "${SELECTED[$index]}" = "1" ]; then
      marker="x"
    else
      marker=" "
    fi
    printf '%s [%s] %s\n' "$pointer" "$marker" "$(feature_name "$feature_dir")"
    index=$((index + 1))
  done
  if [ "$CURSOR" -eq "${#FEATURE_DIRS[@]}" ]; then
    pointer=">"
  else
    pointer=" "
  fi
  printf '%s [ ] Remove Everything\n' "$pointer"
  cat <<'EOF'

Up/Down or j/k = Move
Space = Select
Enter = Uninstall
q = Quit
EOF
}

uninstall_selected() {
  local index=0 removed=0

  for feature_dir in "${FEATURE_DIRS[@]}"; do
    if [ "${SELECTED[$index]}" = "1" ]; then
      "$feature_dir/uninstall.sh"
      removed=$((removed + 1))
    fi
    index=$((index + 1))
  done

  if [ "$removed" -eq 0 ]; then
    info "No features selected."
  else
    info ""
    info "Removed $removed feature(s)."
  fi
}

while true; do
  draw_menu
  IFS= read -rsn1 key || key=""

  case "$key" in
    "")
      uninstall_selected
      exit 0
      ;;
    q|Q)
      exit 0
      ;;
    " ")
      toggle_cursor
      ;;
    j)
      if [ "$CURSOR" -lt "${#FEATURE_DIRS[@]}" ]; then
        CURSOR=$((CURSOR + 1))
      fi
      ;;
    k)
      if [ "$CURSOR" -gt 0 ]; then
        CURSOR=$((CURSOR - 1))
      fi
      ;;
    $'\033')
      IFS= read -rsn2 rest || rest=""
      case "$rest" in
        "[A")
          if [ "$CURSOR" -gt 0 ]; then
            CURSOR=$((CURSOR - 1))
          fi
          ;;
        "[B")
          if [ "$CURSOR" -lt "${#FEATURE_DIRS[@]}" ]; then
            CURSOR=$((CURSOR + 1))
          fi
          ;;
      esac
      ;;
  esac
done
