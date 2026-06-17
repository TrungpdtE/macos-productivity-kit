#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"
source "$(dirname "${BASH_SOURCE[0]}")/i18n.sh"

escape_plist() {
  printf '%s' "$1" |
    sed \
      -e 's/&/\&amp;/g' \
      -e 's/</\&lt;/g' \
      -e 's/>/\&gt;/g' \
      -e 's/"/\&quot;/g'
}

write_workflow() {
  local feature_dir="$1"
  local workflow_path="$2"
  local workflow_name script effective_script accepts input_mode feature_id escaped_id escaped_script escaped_name escaped_accepts escaped_input

  if [ "${MPK_LANG:-en}" = "vi" ]; then
    workflow_name="$(workflow_name_i18n "$feature_dir")"
  else
    workflow_name="$(feature_workflow_name "$feature_dir")"
  fi
  script="$(feature_script "$feature_dir")"
  feature_id="$(feature_id "$feature_dir")"
  effective_script="$(cat <<'SCRIPT'
if [ "$#" -eq 0 ]; then
  finder_items="$(osascript <<'APPLESCRIPT' 2>/dev/null || true
tell application "Finder"
  set output to ""
  if (count of selection) > 0 then
    repeat with itemRef in selection
      set output to output & POSIX path of (itemRef as alias) & linefeed
    end repeat
  else
    try
      set output to POSIX path of (insertion location as alias) & linefeed
    end try
  end if
  return output
end tell
APPLESCRIPT
)"
  if [ -n "$finder_items" ]; then
    old_ifs="$IFS"
    IFS='
'
    set -- $finder_items
    IFS="$old_ifs"
  fi
fi

SCRIPT
)"
  effective_script="${effective_script}
${script}"
  accepts="$(feature_accepts "$feature_dir")"
  input_mode="$(feature_input_mode "$feature_dir")"

  [ -n "$accepts" ] || accepts="public.item"
  [ -n "$input_mode" ] || input_mode="as arguments"

  escaped_script="$(escape_plist "$effective_script")"
  escaped_name="$(escape_plist "$workflow_name")"
  escaped_id="$(escape_plist "$feature_id")"
  escaped_accepts="$(escape_plist "$accepts")"
  escaped_input="$(escape_plist "$input_mode")"

  mkdir -p "$workflow_path/Contents"
  cat >"$workflow_path/Contents/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleDevelopmentRegion</key>
  <string>en</string>
  <key>CFBundleIdentifier</key>
  <string>com.macos-productivity-kit.${escaped_id}</string>
  <key>CFBundleName</key>
  <string>${escaped_name}</string>
  <key>CFBundleShortVersionString</key>
  <string>1.0</string>
  <key>NSServices</key>
  <array>
    <dict>
      <key>NSMenuItem</key>
      <dict>
        <key>default</key>
        <string>${escaped_name}</string>
      </dict>
      <key>NSMessage</key>
      <string>runWorkflowAsService</string>
      <key>NSRequiredContext</key>
      <dict>
        <key>NSApplicationIdentifier</key>
        <string>com.apple.finder</string>
      </dict>
      <key>NSSendFileTypes</key>
      <array>
        <string>${escaped_accepts}</string>
      </array>
    </dict>
  </array>
</dict>
</plist>
EOF

  cat >"$workflow_path/Contents/document.wflow" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>AMDocumentVersion</key>
  <string>2</string>
  <key>AMWorkflowVersion</key>
  <string>2.0</string>
  <key>actions</key>
  <array>
    <dict>
      <key>action</key>
      <dict>
        <key>AMAccepts</key>
        <dict>
          <key>Container</key>
          <string>List</string>
          <key>Optional</key>
          <true/>
          <key>Types</key>
          <array>
            <string>${escaped_accepts}</string>
          </array>
        </dict>
        <key>AMActionVersion</key>
        <string>2.0.3</string>
        <key>AMApplication</key>
        <array>
          <string>Automator</string>
        </array>
        <key>AMParameterProperties</key>
        <dict>
          <key>COMMAND_STRING</key>
          <dict/>
          <key>inputMethod</key>
          <dict/>
          <key>shell</key>
          <dict/>
        </dict>
        <key>AMProvides</key>
        <dict>
          <key>Container</key>
          <string>List</string>
          <key>Types</key>
          <array>
            <string>public.item</string>
          </array>
        </dict>
        <key>ActionBundlePath</key>
        <string>/System/Library/Automator/Run Shell Script.action</string>
        <key>ActionName</key>
        <string>Run Shell Script</string>
        <key>ActionParameters</key>
        <dict>
          <key>COMMAND_STRING</key>
          <string>${escaped_script}</string>
          <key>CheckedForUserDefaultShell</key>
          <true/>
          <key>inputMethod</key>
          <integer>1</integer>
          <key>shell</key>
          <string>/bin/bash</string>
          <key>source</key>
          <string></string>
        </dict>
      </dict>
      <key>isViewVisible</key>
      <false/>
    </dict>
  </array>
  <key>connectors</key>
  <dict/>
  <key>workflowMetaData</key>
  <dict>
    <key>applicationBundleIDsByPath</key>
    <dict>
      <key>/System/Library/CoreServices/Finder.app</key>
      <string>com.apple.finder</string>
    </dict>
    <key>applicationPaths</key>
    <array>
      <string>/System/Library/CoreServices/Finder.app</string>
    </array>
    <key>serviceApplicationBundleIdentifier</key>
    <string>com.apple.finder</string>
    <key>serviceApplicationPath</key>
    <string>/System/Library/CoreServices/Finder.app</string>
    <key>serviceInputTypeIdentifier</key>
    <string>${escaped_accepts}</string>
    <key>serviceInputTypeIdentifierVersion</key>
    <integer>1</integer>
    <key>serviceOutputTypeIdentifier</key>
    <string>com.apple.Automator.nothing</string>
    <key>serviceOutputTypeIdentifierVersion</key>
    <integer>1</integer>
    <key>workflowTypeIdentifier</key>
    <string>com.apple.Automator.servicesMenu</string>
  </dict>
</dict>
</plist>
EOF
}

install_feature_workflow() {
  local feature_dir="$1"
  local id workflow_path

  id="$(feature_id "$feature_dir")"
  workflow_path="$(workflow_path_for_feature "$feature_dir")"

  ensure_dir "$SERVICES_DIR"
  if ! confirm_overwrite "$workflow_path"; then
    info "Skipped $(feature_name "$feature_dir")."
    return 0
  fi

  rm -rf "$workflow_path"
  write_workflow "$feature_dir" "$workflow_path"
  record_installed_feature "$id"
  info "Installed $(feature_name "$feature_dir")"
}

if [ "${1:-}" ]; then
  install_feature_workflow "$1"
else
  discover_features | while IFS= read -r feature_dir; do
    install_feature_workflow "$feature_dir"
  done
fi
