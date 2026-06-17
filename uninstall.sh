#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/scripts/utils.sh"
source "$(dirname "${BASH_SOURCE[0]}")/scripts/i18n.sh"

ui_text() {
  local key="$1"
  if [ "${MPK_LANG:-en}" = "vi" ]; then
    case "$key" in
      title) printf 'Trình gỡ macOS Productivity Kit' ;;
      select_features) printf 'Chọn tính năng muốn gỡ' ;;
      remove_everything) printf 'Gỡ tất cả' ;;
      move) printf 'Lên/Xuống hoặc j/k = Di chuyển' ;;
      select) printf 'Space = Chọn/Bỏ chọn' ;;
      all) printf 'a = Chọn/Bỏ chọn tất cả' ;;
      enter) printf 'Enter = Gỡ cài đặt' ;;
      quit) printf 'q = Thoát' ;;
      *) printf '%s' "$key" ;;
    esac
  else
    case "$key" in
      title) printf 'macOS Productivity Kit Uninstaller' ;;
      select_features) printf 'Select installed features to remove' ;;
      remove_everything) printf 'Remove Everything' ;;
      move) printf 'Up/Down or j/k = Move' ;;
      select) printf 'Space = Select' ;;
      all) printf 'a = Select/Deselect All' ;;
      enter) printf 'Enter = Uninstall' ;;
      quit) printf 'q = Quit' ;;
      *) printf '%s' "$key" ;;
    esac
  fi
}

print_header() {
  clear 2>/dev/null || true
  cat <<EOF
====================================
 $(ui_text title)
====================================

$(ui_text select_features)

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
  [ "${MPK_LANG:-en}" = "vi" ] && info "Chưa ghi nhận tính năng nào đã cài." || info "No installed features recorded."
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
    toggle_all
    return 0
  fi

  if [ "${SELECTED[$index]}" = "1" ]; then
    SELECTED[$index]="0"
  else
    SELECTED[$index]="1"
  fi
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
  printf '%s [%s] %s\n' "$pointer" "$marker" "$(ui_text remove_everything)"
  cat <<EOF

$(ui_text move)
$(ui_text select)
$(ui_text all)
$(ui_text enter)
$(ui_text quit)
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
    [ "${MPK_LANG:-en}" = "vi" ] && info "Chưa chọn tính năng nào." || info "No features selected."
  else
    info ""
    [ "${MPK_LANG:-en}" = "vi" ] && info "Đã gỡ $removed tính năng." || info "Removed $removed feature(s)."
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
