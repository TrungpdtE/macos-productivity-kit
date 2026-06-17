#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/scripts/utils.sh"

print_header() {
  clear 2>/dev/null || true
  cat <<'EOF'
==================================
 macOS Productivity Kit Installer
==================================

Select features to install

EOF
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
  if all_selected; then
    marker="x"
  else
    marker=" "
  fi
  printf '%s [%s] Install Everything\n' "$pointer" "$marker"
  cat <<'EOF'

Up/Down or j/k = Move
Space = Select
a = Select/Deselect All
Enter = Install
q = Quit
EOF
}

all_selected() {
  local selected

  for selected in "${SELECTED[@]}"; do
    [ "$selected" = "1" ] || return 1
  done
  return 0
}

toggle_all() {
  local value="1"

  if all_selected; then
    value="0"
  fi

  for i in "${!SELECTED[@]}"; do
    SELECTED[$i]="$value"
  done
}

toggle_cursor() {
  local index="$CURSOR"

  if [ "$index" -eq "${#FEATURE_DIRS[@]}" ]; then
    toggle_all
    return 0
  fi

  if [ "${SELECTED[$index]}" = "1" ]; then
    SELECTED[$index]="0"
  else
    SELECTED[$index]="1"
  fi
}

install_selected() {
  local index=0 installed=0

  for feature_dir in "${FEATURE_DIRS[@]}"; do
    if [ "${SELECTED[$index]}" = "1" ]; then
      "$feature_dir/install.sh"
      installed=$((installed + 1))
    fi
    index=$((index + 1))
  done

  if [ "$installed" -eq 0 ]; then
    info "No features selected."
  else
    info ""
    info "Installed $installed feature(s)."
    info "Open System Settings > Keyboard > Keyboard Shortcuts > Services to assign shortcuts."
  fi
}

FEATURE_DIRS=()
while IFS= read -r feature_dir; do
  FEATURE_DIRS+=("$feature_dir")
done < <(discover_features)
[ "${#FEATURE_DIRS[@]}" -gt 0 ] || die "no features found"

SELECTED=()
for _ in "${FEATURE_DIRS[@]}"; do
  SELECTED+=("0")
done
CURSOR=0

while true; do
  draw_menu
  IFS= read -rsn1 key || key=""

  case "$key" in
    "")
      install_selected
      exit 0
      ;;
    q|Q)
      exit 0
      ;;
    " ")
      toggle_cursor
      ;;
    a|A)
      toggle_all
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
