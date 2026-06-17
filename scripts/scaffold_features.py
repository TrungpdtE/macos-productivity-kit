#!/usr/bin/env python3
"""Generate first-party feature folders.

The runtime installer does not depend on this file. It only scaffolds the
repository's bundled features so every feature owns its manifest and scripts.
"""

from __future__ import annotations

import json
from pathlib import Path
from textwrap import dedent


ROOT = Path(__file__).resolve().parents[1]
FEATURES_DIR = ROOT / "features"


def script(body: str) -> str:
    return dedent(body).strip() + "\n"


COMMON_TARGET = r'''
target="${1:-$PWD}"
if [ -f "$target" ]; then
  target="$(dirname "$target")"
fi
'''


FEATURES = [
    {
        "id": "open-terminal",
        "name": "Open Terminal Here",
        "category": "Finder",
        "workflow_name": "Open Terminal Here",
        "description": "Open Terminal in the selected Finder folder.",
        "script": script(COMMON_TARGET + 'open -a Terminal "$target"'),
    },
    {
        "id": "open-ghostty",
        "name": "Open Ghostty Here",
        "category": "Finder",
        "workflow_name": "Open Ghostty Here",
        "description": "Open Ghostty in the selected Finder folder.",
        "script": script(COMMON_TARGET + 'open -a Ghostty "$target"'),
    },
    {
        "id": "open-iterm",
        "name": "Open iTerm Here",
        "category": "Finder",
        "workflow_name": "Open iTerm Here",
        "description": "Open iTerm in the selected Finder folder.",
        "script": script(COMMON_TARGET + 'open -a iTerm "$target"'),
    },
    {
        "id": "open-vscode",
        "name": "Open VSCode Here",
        "category": "Finder",
        "workflow_name": "Open VSCode Here",
        "description": "Open the selected folder in Visual Studio Code.",
        "script": script(COMMON_TARGET + 'open -a "Visual Studio Code" "$target"'),
    },
    {
        "id": "open-cursor",
        "name": "Open Cursor Here",
        "category": "Finder",
        "workflow_name": "Open Cursor Here",
        "description": "Open the selected folder in Cursor.",
        "script": script(COMMON_TARGET + 'open -a Cursor "$target"'),
    },
    {
        "id": "open-intellij",
        "name": "Open IntelliJ Here",
        "category": "Finder",
        "workflow_name": "Open IntelliJ Here",
        "description": "Open the selected folder in IntelliJ IDEA.",
        "script": script(COMMON_TARGET + 'open -a "IntelliJ IDEA" "$target"'),
    },
    {
        "id": "copy-path",
        "name": "Copy Full Path",
        "category": "Finder",
        "workflow_name": "Copy Full Path",
        "description": "Copy selected Finder item paths to the clipboard.",
        "script": script('printf "%s\\n" "$@" | pbcopy'),
    },
    {
        "id": "copy-relative-path",
        "name": "Copy Relative Path",
        "category": "Finder",
        "workflow_name": "Copy Relative Path",
        "description": "Copy selected item paths relative to the git root or current folder.",
        "script": script(r'''
base="$(git -C "$(dirname "${1:-$PWD}")" rev-parse --show-toplevel 2>/dev/null || pwd)"
for item in "$@"; do
  case "$item" in
    "$base"/*) printf '%s\n' "${item#$base/}" ;;
    *) printf '%s\n' "$item" ;;
  esac
done | pbcopy
'''),
    },
    {
        "id": "create-empty-file",
        "name": "Create Empty Text File",
        "category": "Finder",
        "workflow_name": "Create Empty Text File",
        "description": "Create untitled.txt in the selected folder.",
        "script": script(COMMON_TARGET + r'''
file="$target/untitled.txt"
i=1
while [ -e "$file" ]; do
  file="$target/untitled-$i.txt"
  i=$((i + 1))
done
: >"$file"
open -R "$file"
'''),
    },
    {
        "id": "create-markdown-file",
        "name": "Create Markdown File",
        "category": "Finder",
        "workflow_name": "Create Markdown File",
        "description": "Create untitled.md in the selected folder.",
        "script": script(COMMON_TARGET + r'''
file="$target/untitled.md"
i=1
while [ -e "$file" ]; do
  file="$target/untitled-$i.md"
  i=$((i + 1))
done
printf "# Untitled\n" >"$file"
open -R "$file"
'''),
    },
    {
        "id": "duplicate-as-backup",
        "name": "Duplicate As Backup",
        "category": "Finder",
        "workflow_name": "Duplicate As Backup",
        "description": "Duplicate selected files with a timestamped .backup suffix.",
        "script": script(r'''
stamp="$(date +%Y%m%d-%H%M%S)"
for item in "$@"; do
  cp -R "$item" "$item.backup-$stamp"
done
'''),
    },
    {
        "id": "zip-folder",
        "name": "Compress Folder",
        "category": "Finder",
        "workflow_name": "Compress Folder",
        "description": "Create zip archives for selected files or folders.",
        "script": script(r'''
for item in "$@"; do
  parent="$(dirname "$item")"
  name="$(basename "$item")"
  (cd "$parent" && /usr/bin/zip -r "$name.zip" "$name")
done
'''),
    },
    {
        "id": "extract-zip",
        "name": "Extract Zip",
        "category": "Finder",
        "workflow_name": "Extract Zip",
        "description": "Extract selected zip files beside the original archive.",
        "script": script(r'''
for item in "$@"; do
  case "$item" in
    *.zip) unzip -q "$item" -d "$(dirname "$item")" ;;
  esac
done
'''),
    },
    {
        "id": "toggle-hidden-files",
        "name": "Reveal Hidden Files Toggle",
        "category": "Finder",
        "workflow_name": "Reveal Hidden Files Toggle",
        "description": "Toggle Finder hidden file visibility.",
        "script": script(r'''
current="$(defaults read com.apple.finder AppleShowAllFiles 2>/dev/null || printf false)"
if [ "$current" = "true" ] || [ "$current" = "1" ]; then
  defaults write com.apple.finder AppleShowAllFiles -bool false
else
  defaults write com.apple.finder AppleShowAllFiles -bool true
fi
killall Finder
'''),
    },
    {
        "id": "toggle-file-extensions",
        "name": "Toggle File Extensions",
        "category": "Finder",
        "workflow_name": "Toggle File Extensions",
        "description": "Toggle Finder file extension visibility.",
        "script": script(r'''
current="$(defaults read NSGlobalDomain AppleShowAllExtensions 2>/dev/null || printf false)"
if [ "$current" = "true" ] || [ "$current" = "1" ]; then
  defaults write NSGlobalDomain AppleShowAllExtensions -bool false
else
  defaults write NSGlobalDomain AppleShowAllExtensions -bool true
fi
killall Finder
'''),
    },
    {
        "id": "empty-trash",
        "name": "Empty Trash",
        "category": "Finder",
        "workflow_name": "Empty Trash",
        "description": "Empty the current user's Trash.",
        "script": script('osascript -e \'tell application "Finder" to empty trash\''),
    },
    {
        "id": "restart-finder",
        "name": "Restart Finder",
        "category": "Finder",
        "workflow_name": "Restart Finder",
        "description": "Restart Finder.",
        "script": script('killall Finder'),
    },
    {
        "id": "open-current-folder-browser",
        "name": "Open Current Folder In Browser",
        "category": "Finder",
        "workflow_name": "Open Current Folder In Browser",
        "description": "Open the selected folder through the default browser as a file URL.",
        "script": script(COMMON_TARGET + 'open "file://$target"'),
    },
    {
        "id": "open-current-folder-github-desktop",
        "name": "Open Current Folder In GitHub Desktop",
        "category": "Finder",
        "workflow_name": "Open Current Folder In GitHub Desktop",
        "description": "Open the selected folder in GitHub Desktop.",
        "script": script(COMMON_TARGET + 'open -a "GitHub Desktop" "$target"'),
    },
    {
        "id": "generate-gitignore",
        "name": "Generate .gitignore",
        "category": "Developer",
        "workflow_name": "Generate .gitignore",
        "description": "Create a practical default .gitignore.",
        "script": script(COMMON_TARGET + r'''
cat >"$target/.gitignore" <<'EOF'
.DS_Store
node_modules/
.venv/
__pycache__/
*.pyc
.env
dist/
build/
target/
EOF
'''),
    },
    {
        "id": "create-readme",
        "name": "Create README.md",
        "category": "Developer",
        "workflow_name": "Create README.md",
        "description": "Create a starter README.md.",
        "script": script(COMMON_TARGET + r'''
name="$(basename "$target")"
cat >"$target/README.md" <<EOF
# $name

## Overview

## Installation

## Usage
EOF
'''),
    },
    {
        "id": "create-license",
        "name": "Create LICENSE",
        "category": "Developer",
        "workflow_name": "Create LICENSE",
        "description": "Create an MIT LICENSE file.",
        "script": script(COMMON_TARGET + r'''
year="$(date +%Y)"
cat >"$target/LICENSE" <<EOF
MIT License

Copyright (c) $year

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files to deal in the Software
without restriction, subject to inclusion of this notice.
EOF
'''),
    },
    {
        "id": "initialize-git",
        "name": "Initialize Git Repository",
        "category": "Developer",
        "workflow_name": "Initialize Git Repository",
        "description": "Run git init in the selected folder.",
        "script": script(COMMON_TARGET + 'git -C "$target" init'),
    },
    {
        "id": "initialize-python-project",
        "name": "Initialize Python Project",
        "category": "Developer",
        "workflow_name": "Initialize Python Project",
        "description": "Create a small Python project skeleton.",
        "script": script(COMMON_TARGET + r'''
mkdir -p "$target/src" "$target/tests"
: >"$target/src/__init__.py"
cat >"$target/pyproject.toml" <<'EOF'
[project]
name = "app"
version = "0.1.0"
requires-python = ">=3.9"
EOF
'''),
    },
    {
        "id": "initialize-java-project",
        "name": "Initialize Java Project",
        "category": "Developer",
        "workflow_name": "Initialize Java Project",
        "description": "Create a basic Java source layout.",
        "script": script(COMMON_TARGET + r'''
mkdir -p "$target/src/main/java" "$target/src/test/java"
cat >"$target/src/main/java/Main.java" <<'EOF'
public class Main {
    public static void main(String[] args) {
        System.out.println("Hello, world");
    }
}
EOF
'''),
    },
    {
        "id": "initialize-node-project",
        "name": "Initialize Node Project",
        "category": "Developer",
        "workflow_name": "Initialize Node Project",
        "description": "Create package.json if npm is available.",
        "script": script(COMMON_TARGET + r'''
if command -v npm >/dev/null 2>&1; then
  (cd "$target" && npm init -y)
else
  cat >"$target/package.json" <<'EOF'
{"name":"app","version":"0.1.0","scripts":{}}
EOF
fi
'''),
    },
    {
        "id": "initialize-docker-project",
        "name": "Initialize Docker Project",
        "category": "Developer",
        "workflow_name": "Initialize Docker Project",
        "description": "Create Dockerfile and .dockerignore.",
        "script": script(COMMON_TARGET + r'''
cat >"$target/Dockerfile" <<'EOF'
FROM alpine:latest
WORKDIR /app
CMD ["sh"]
EOF
cat >"$target/.dockerignore" <<'EOF'
.git
node_modules
.venv
EOF
'''),
    },
    {
        "id": "create-env",
        "name": "Create .env",
        "category": "Developer",
        "workflow_name": "Create .env",
        "description": "Create an empty .env file.",
        "script": script(COMMON_TARGET + ': >"$target/.env"'),
    },
    {
        "id": "create-env-example",
        "name": "Create .env.example",
        "category": "Developer",
        "workflow_name": "Create .env.example",
        "description": "Create an empty .env.example file.",
        "script": script(COMMON_TARGET + ': >"$target/.env.example"'),
    },
    {
        "id": "convert-png-jpg",
        "name": "Convert PNG to JPG",
        "category": "File Utilities",
        "workflow_name": "Convert PNG to JPG",
        "description": "Convert selected PNG files to JPG using sips.",
        "script": script(r'''
for item in "$@"; do
  case "$item" in
    *.png|*.PNG) sips -s format jpeg "$item" --out "${item%.*}.jpg" >/dev/null ;;
  esac
done
'''),
    },
    {
        "id": "convert-jpg-png",
        "name": "Convert JPG to PNG",
        "category": "File Utilities",
        "workflow_name": "Convert JPG to PNG",
        "description": "Convert selected JPG files to PNG using sips.",
        "script": script(r'''
for item in "$@"; do
  case "$item" in
    *.jpg|*.jpeg|*.JPG|*.JPEG) sips -s format png "$item" --out "${item%.*}.png" >/dev/null ;;
  esac
done
'''),
    },
    {
        "id": "resize-images",
        "name": "Resize Images",
        "category": "File Utilities",
        "workflow_name": "Resize Images",
        "description": "Create 1200px-wide copies of selected images.",
        "script": script(r'''
for item in "$@"; do
  output="${item%.*}-1200.${item##*.}"
  sips --resampleWidth 1200 "$item" --out "$output" >/dev/null
done
'''),
    },
    {
        "id": "create-pdf-from-images",
        "name": "Create PDF from Images",
        "category": "File Utilities",
        "workflow_name": "Create PDF from Images",
        "description": "Create a PDF from selected images.",
        "script": script(r'''
out="$(dirname "${1:-$PWD}")/images-$(date +%Y%m%d-%H%M%S).pdf"
/System/Library/Automator/Combine\ PDF\ Pages.action/Contents/Resources/join.py -o "$out" "$@" 2>/dev/null || printf "PDF creation failed\n" >&2
'''),
    },
    {
        "id": "merge-pdfs",
        "name": "Merge PDFs",
        "category": "File Utilities",
        "workflow_name": "Merge PDFs",
        "description": "Merge selected PDFs into one PDF.",
        "script": script(r'''
out="$(dirname "${1:-$PWD}")/merged-$(date +%Y%m%d-%H%M%S).pdf"
/System/Library/Automator/Combine\ PDF\ Pages.action/Contents/Resources/join.py -o "$out" "$@" 2>/dev/null || printf "PDF merge failed\n" >&2
'''),
    },
    {
        "id": "rename-files-sequentially",
        "name": "Rename Files Sequentially",
        "category": "File Utilities",
        "workflow_name": "Rename Files Sequentially",
        "description": "Rename selected files to file-001.ext, file-002.ext, and so on.",
        "script": script(r'''
i=1
for item in "$@"; do
  dir="$(dirname "$item")"
  ext="${item##*.}"
  mv "$item" "$dir/file-$(printf "%03d" "$i").$ext"
  i=$((i + 1))
done
'''),
    },
    {
        "id": "lowercase-file-names",
        "name": "Lowercase File Names",
        "category": "File Utilities",
        "workflow_name": "Lowercase File Names",
        "description": "Rename selected files to lowercase.",
        "script": script(r'''
for item in "$@"; do
  dir="$(dirname "$item")"
  base="$(basename "$item")"
  lower="$(printf "%s" "$base" | tr "[:upper:]" "[:lower:]")"
  [ "$base" = "$lower" ] || mv "$item" "$dir/$lower"
done
'''),
    },
    {
        "id": "uppercase-file-names",
        "name": "Uppercase File Names",
        "category": "File Utilities",
        "workflow_name": "Uppercase File Names",
        "description": "Rename selected files to uppercase.",
        "script": script(r'''
for item in "$@"; do
  dir="$(dirname "$item")"
  base="$(basename "$item")"
  upper="$(printf "%s" "$base" | tr "[:lower:]" "[:upper:]")"
  [ "$base" = "$upper" ] || mv "$item" "$dir/$upper"
done
'''),
    },
    {
        "id": "remove-spaces-file-names",
        "name": "Remove Spaces From File Names",
        "category": "File Utilities",
        "workflow_name": "Remove Spaces From File Names",
        "description": "Replace spaces in selected file names with hyphens.",
        "script": script(r'''
for item in "$@"; do
  dir="$(dirname "$item")"
  base="$(basename "$item")"
  clean="$(printf "%s" "$base" | tr " " "-")"
  [ "$base" = "$clean" ] || mv "$item" "$dir/$clean"
done
'''),
    },
    {
        "id": "copy-file-name",
        "name": "Copy File Name",
        "category": "Clipboard",
        "workflow_name": "Copy File Name",
        "description": "Copy selected file names to the clipboard.",
        "script": script('for item in "$@"; do basename "$item"; done | pbcopy'),
    },
    {
        "id": "copy-directory-name",
        "name": "Copy Directory Name",
        "category": "Clipboard",
        "workflow_name": "Copy Directory Name",
        "description": "Copy selected parent directory names to the clipboard.",
        "script": script('for item in "$@"; do basename "$(dirname "$item")"; done | pbcopy'),
    },
    {
        "id": "copy-file-size",
        "name": "Copy File Size",
        "category": "Clipboard",
        "workflow_name": "Copy File Size",
        "description": "Copy selected file sizes to the clipboard.",
        "script": script('du -sh "$@" | pbcopy'),
    },
    {
        "id": "copy-sha256",
        "name": "Copy SHA256",
        "category": "Clipboard",
        "workflow_name": "Copy SHA256",
        "description": "Copy SHA256 checksums for selected files.",
        "script": script('shasum -a 256 "$@" | pbcopy'),
    },
    {
        "id": "timestamp-file",
        "name": "Timestamp File",
        "category": "Productivity",
        "workflow_name": "Timestamp File",
        "description": "Append a timestamp to selected file names.",
        "script": script(r'''
stamp="$(date +%Y%m%d-%H%M%S)"
for item in "$@"; do
  dir="$(dirname "$item")"
  base="$(basename "$item")"
  mv "$item" "$dir/$stamp-$base"
done
'''),
    },
    {
        "id": "create-todays-note",
        "name": "Create Today's Note",
        "category": "Productivity",
        "workflow_name": "Create Today's Note",
        "description": "Create a dated Markdown note in the selected folder.",
        "script": script(COMMON_TARGET + r'''
file="$target/$(date +%Y-%m-%d).md"
printf "# %s\n\n" "$(date +%Y-%m-%d)" >"$file"
open "$file"
'''),
    },
    {
        "id": "archive-folder",
        "name": "Archive Folder",
        "category": "Productivity",
        "workflow_name": "Archive Folder",
        "description": "Move selected items into an Archive folder.",
        "script": script(r'''
for item in "$@"; do
  dir="$(dirname "$item")"
  mkdir -p "$dir/Archive"
  mv "$item" "$dir/Archive/"
done
'''),
    },
    {
        "id": "sort-downloads",
        "name": "Sort Downloads",
        "category": "Productivity",
        "workflow_name": "Sort Downloads",
        "description": "Sort common Downloads file types into folders.",
        "script": script(r'''
downloads="$HOME/Downloads"
mkdir -p "$downloads/Images" "$downloads/PDFs" "$downloads/Archives" "$downloads/Installers"
find "$downloads" -maxdepth 1 -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" \) -exec mv {} "$downloads/Images/" \;
find "$downloads" -maxdepth 1 -type f -iname "*.pdf" -exec mv {} "$downloads/PDFs/" \;
find "$downloads" -maxdepth 1 -type f \( -iname "*.zip" -o -iname "*.tar.gz" \) -exec mv {} "$downloads/Archives/" \;
find "$downloads" -maxdepth 1 -type f -iname "*.dmg" -exec mv {} "$downloads/Installers/" \;
'''),
    },
    {
        "id": "move-screenshots",
        "name": "Move Screenshots",
        "category": "Productivity",
        "workflow_name": "Move Screenshots",
        "description": "Move screenshots from Desktop into a Screenshots folder.",
        "script": script(r'''
dest="$HOME/Pictures/Screenshots"
mkdir -p "$dest"
find "$HOME/Desktop" -maxdepth 1 -type f -name "Screenshot*.png" -exec mv {} "$dest/" \;
'''),
    },
    {
        "id": "quick-rename",
        "name": "Quick Rename",
        "category": "Productivity",
        "workflow_name": "Quick Rename",
        "description": "Prompt for a new base name and rename selected files.",
        "script": script(r'''
name="$(osascript -e 'text returned of (display dialog "New base name" default answer "file")')"
i=1
for item in "$@"; do
  dir="$(dirname "$item")"
  ext="${item##*.}"
  mv "$item" "$dir/$name-$(printf "%03d" "$i").$ext"
  i=$((i + 1))
done
'''),
    },
    {
        "id": "finder-cleanup",
        "name": "Finder Cleanup",
        "category": "Finder",
        "workflow_name": "Finder Cleanup",
        "description": "Remove .DS_Store files from selected folders.",
        "script": script(r'''
for item in "$@"; do
  if [ -d "$item" ]; then
    find "$item" -name .DS_Store -delete
  fi
done
'''),
    },
    {
        "id": "developer-utilities",
        "name": "Developer Utilities",
        "category": "Developer",
        "workflow_name": "Developer Utilities",
        "description": "Create common developer utility files in the selected folder.",
        "script": script(COMMON_TARGET + r'''
: >"$target/.env.example"
: >"$target/README.md"
: >"$target/.gitignore"
'''),
    },
]


def write_feature(feature: dict[str, str]) -> None:
    feature_dir = FEATURES_DIR / feature["id"]
    assets_dir = feature_dir / "assets"
    assets_dir.mkdir(parents=True, exist_ok=True)

    manifest = {
        "id": feature["id"],
        "name": feature["name"],
        "category": feature["category"],
        "workflow_name": feature["workflow_name"],
        "description": feature["description"],
        "type": "automator-workflow",
        "accepts": feature.get("accepts", "public.item"),
        "input_mode": feature.get("input_mode", "as arguments"),
        "script": feature["script"],
    }

    (feature_dir / "feature.json").write_text(
        json.dumps(manifest, indent=2, ensure_ascii=False) + "\n",
        encoding="utf-8",
    )
    (feature_dir / "install.sh").write_text(
        dedent(
            """\
            #!/usr/bin/env bash
            set -euo pipefail

            feature_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
            "$feature_dir/../../scripts/feature_runner.sh" install "$feature_dir"
            """
        ),
        encoding="utf-8",
    )
    (feature_dir / "uninstall.sh").write_text(
        dedent(
            """\
            #!/usr/bin/env bash
            set -euo pipefail

            feature_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
            "$feature_dir/../../scripts/feature_runner.sh" uninstall "$feature_dir"
            """
        ),
        encoding="utf-8",
    )
    (feature_dir / "README.md").write_text(
        dedent(
            f"""\
            # {feature["name"]}

            Category: {feature["category"]}

            {feature["description"]}

            ## Install

            ```sh
            ./install.sh
            ```

            ## Uninstall

            ```sh
            ./uninstall.sh
            ```
            """
        ),
        encoding="utf-8",
    )
    (assets_dir / ".gitkeep").write_text("", encoding="utf-8")
    (feature_dir / "install.sh").chmod(0o755)
    (feature_dir / "uninstall.sh").chmod(0o755)


def main() -> None:
    FEATURES_DIR.mkdir(parents=True, exist_ok=True)
    for feature in FEATURES:
        write_feature(feature)
    print(f"Generated {len(FEATURES)} features.")


if __name__ == "__main__":
    main()
