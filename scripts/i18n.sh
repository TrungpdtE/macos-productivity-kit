#!/usr/bin/env bash

feature_name_i18n() {
  local feature_dir="$1"
  local id
  id="$(feature_id "$feature_dir")"
  if [ "${MPK_LANG:-en}" != "vi" ]; then
    feature_name "$feature_dir"
    return 0
  fi
  case "$id" in
    archive-folder) printf 'Lưu vào thư mục Archive' ;;
    convert-jpg-png) printf 'Chuyển JPG sang PNG' ;;
    convert-png-jpg) printf 'Chuyển PNG sang JPG' ;;
    copy-directory-name) printf 'Sao chép tên thư mục' ;;
    copy-file-name) printf 'Sao chép tên tệp' ;;
    copy-file-size) printf 'Sao chép dung lượng tệp' ;;
    copy-path) printf 'Sao chép đường dẫn đầy đủ' ;;
    copy-relative-path) printf 'Sao chép đường dẫn tương đối' ;;
    copy-sha256) printf 'Sao chép SHA256' ;;
    create-empty-file) printf 'Tạo tệp text rỗng' ;;
    create-env) printf 'Tạo .env' ;;
    create-env-example) printf 'Tạo .env.example' ;;
    create-license) printf 'Tạo LICENSE' ;;
    create-markdown-file) printf 'Tạo tệp Markdown' ;;
    create-pdf-from-images) printf 'Tạo PDF từ ảnh' ;;
    create-readme) printf 'Tạo README.md' ;;
    create-todays-note) printf 'Tạo ghi chú hôm nay' ;;
    developer-utilities) printf 'Tiện ích lập trình' ;;
    duplicate-as-backup) printf 'Nhân bản làm bản sao lưu' ;;
    empty-trash) printf 'Dọn thùng rác' ;;
    extract-zip) printf 'Giải nén ZIP' ;;
    finder-cleanup) printf 'Dọn file rác Finder' ;;
    generate-gitignore) printf 'Tạo .gitignore' ;;
    initialize-docker-project) printf 'Khởi tạo dự án Docker' ;;
    initialize-git) printf 'Khởi tạo Git repository' ;;
    initialize-java-project) printf 'Khởi tạo dự án Java' ;;
    initialize-node-project) printf 'Khởi tạo dự án Node' ;;
    initialize-python-project) printf 'Khởi tạo dự án Python' ;;
    lowercase-file-names) printf 'Đổi tên tệp thành chữ thường' ;;
    merge-pdfs) printf 'Gộp PDF' ;;
    move-screenshots) printf 'Di chuyển ảnh chụp màn hình' ;;
    open-current-folder-browser) printf 'Mở thư mục hiện tại trong trình duyệt' ;;
    open-current-folder-github-desktop) printf 'Mở thư mục hiện tại trong GitHub Desktop' ;;
    open-cursor) printf 'Mở Cursor tại đây' ;;
    open-ghostty) printf 'Mở Ghostty tại đây' ;;
    open-intellij) printf 'Mở IntelliJ tại đây' ;;
    open-iterm) printf 'Mở iTerm tại đây' ;;
    open-terminal) printf 'Mở Terminal tại đây' ;;
    open-vscode) printf 'Mở VSCode tại đây' ;;
    quick-rename) printf 'Đổi tên nhanh' ;;
    remove-spaces-file-names) printf 'Xóa khoảng trắng trong tên tệp' ;;
    rename-files-sequentially) printf 'Đổi tên tuần tự' ;;
    resize-images) printf 'Đổi kích thước ảnh' ;;
    restart-finder) printf 'Khởi động lại Finder' ;;
    sort-downloads) printf 'Sắp xếp thư mục Downloads' ;;
    timestamp-file) printf 'Thêm timestamp vào tên tệp' ;;
    toggle-file-extensions) printf 'Bật/tắt hiện phần mở rộng tệp' ;;
    toggle-hidden-files) printf 'Bật/tắt hiện tệp ẩn' ;;
    uppercase-file-names) printf 'Đổi tên tệp thành chữ hoa' ;;
    zip-folder) printf 'Nén thư mục' ;;
    *) feature_name "$feature_dir" ;;
  esac
}

workflow_name_i18n() {
  feature_name_i18n "$1"
}

workflow_bundle_display_name_i18n() {
  workflow_name_i18n "$1"
}
