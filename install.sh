#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/scripts/utils.sh"
source "$(dirname "${BASH_SOURCE[0]}")/scripts/i18n.sh"

ui_text() {
  local key="$1"
  if [ "${MPK_LANG:-en}" = "vi" ]; then
    case "$key" in
      title) printf 'Trình cài macOS Productivity Kit' ;;
      select_features) printf 'Chọn tính năng muốn cài' ;;
      install_everything) printf 'Cài tất cả' ;;
      move) printf 'Lên/Xuống hoặc j/k = Di chuyển' ;;
      select) printf 'Space = Chọn/Bỏ chọn' ;;
      all) printf 'a = Chọn/Bỏ chọn tất cả' ;;
      enter) printf 'Enter = Cài đặt' ;;
      quit) printf 'q = Thoát' ;;
      *) printf '%s' "$key" ;;
    esac
  else
    case "$key" in
      title) printf 'macOS Productivity Kit Installer' ;;
      select_features) printf 'Select features to install' ;;
      install_everything) printf 'Install Everything' ;;
      move) printf 'Up/Down or j/k = Move' ;;
      select) printf 'Space = Select' ;;
      all) printf 'a = Select/Deselect All' ;;
      enter) printf 'Enter = Install' ;;
      quit) printf 'q = Quit' ;;
      *) printf '%s' "$key" ;;
    esac
  fi
}

print_header() {
  clear 2>/dev/null || true
  cat <<EOF
==================================
 $(ui_text title)
==================================

$(ui_text select_features)

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
    printf '%s [%s] %s\n' "$pointer" "$marker" "$(feature_name_i18n "$feature_dir")"
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
  printf '%s [%s] %s\n' "$pointer" "$marker" "$(ui_text install_everything)"
  cat <<EOF

$(ui_text move)
$(ui_text select)
$(ui_text all)
$(ui_text enter)
$(ui_text quit)
EOF
}

selected_feature_dirs() {
  local i feature_dir

  for i in "${!FEATURE_DIRS[@]}"; do
    if [ "${SELECTED[$i]}" = "1" ]; then
      feature_dir="${FEATURE_DIRS[$i]}"
      printf '%s\n' "$feature_dir"
    fi
  done
}

prompt_overwrite_if_needed() {
  local feature_dir path answer

  [ -z "${MPK_OVERWRITE_DECISION:-}" ] || return 0
  [ "${MPK_FORCE_OVERWRITE:-0}" = "1" ] && return 0

  while IFS= read -r feature_dir; do
    path="$(workflow_path_for_feature "$feature_dir")"
    if [ -e "$path" ] && ! workflow_path_is_owned "$path"; then
      printf 'One or more workflows already exist.\n'
      printf 'Overwrite existing workflows for this install? [y/N] '
      IFS= read -r answer
      case "$answer" in
        y|Y|yes|YES) MPK_OVERWRITE_DECISION="yes" ;;
        *) MPK_OVERWRITE_DECISION="no" ;;
      esac
      export MPK_OVERWRITE_DECISION
      return 0
    fi
  done < <(selected_feature_dirs)
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
  local feature_dir

  prompt_overwrite_if_needed
  for feature_dir in "${FEATURE_DIRS[@]}"; do
    if [ "${SELECTED[$index]}" = "1" ]; then
      "$feature_dir/install.sh"
      installed=$((installed + 1))
    fi
    index=$((index + 1))
  done

  if [ "$installed" -eq 0 ]; then
    [ "${MPK_LANG:-en}" = "vi" ] && info "Chưa chọn tính năng nào." || info "No features selected."
  else
    info ""
    if [ "${MPK_LANG:-en}" = "vi" ]; then
      info "Đã cài $installed tính năng."
      info "Mở System Settings > Keyboard > Keyboard Shortcuts > Services để gán phím tắt."
    else
      info "Installed $installed feature(s)."
      info "Open System Settings > Keyboard > Keyboard Shortcuts > Services to assign shortcuts."
    fi
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
