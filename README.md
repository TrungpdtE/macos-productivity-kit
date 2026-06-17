# macOS Productivity Kit

One-click installation for useful macOS Quick Actions, Finder Services, Automator Workflows, Shortcuts, and developer productivity tools.

The project is feature-driven: every feature lives in `features/<feature-id>/` with its own manifest and install/uninstall scripts. The main installer discovers features automatically, so adding a new feature does not require changing installer logic.

## Screenshots

Installer preview:

```text
==================================
 macOS Productivity Kit Installer
==================================

Select features to install

[ ] Open Terminal Here
[ ] Open Ghostty Here
[ ] Open VSCode Here
[ ] Create Empty Text File
[ ] Copy Full Path
[ ] Compress Folder
[ ] Duplicate As Backup
[ ] Reveal Hidden Files Toggle
[ ] Developer Utilities

Up/Down or j/k = Move
Space = Select
Enter = Install
```

After installation, features appear in Finder under:

```text
Right click file or folder > Quick Actions
Right click file or folder > Services
```

## Supported macOS Versions

- macOS Monterey and newer are recommended
- Automator Services are supported on Intel Macs and Apple Silicon Macs
- Shortcuts can be added on newer macOS versions, but bundled features prefer Automator workflows for broad compatibility

No Homebrew, sudo, or external dependencies are required.

## Installation

```sh
git clone https://github.com/your-name/macos-productivity-kit.git
cd macos-productivity-kit
./install.sh
```

Use Up/Down or `j`/`k` to move, Space to select, and Enter to install selected features. Select `Install Everything` to enable every bundled feature.

Workflows are installed into:

```text
~/Library/Services
```

The installer asks before overwriting an existing workflow with the same name.

## Uninstall

```sh
./uninstall.sh
```

The uninstaller lists installed features recorded by the kit and lets you remove selected workflows.

## Supported Features

Finder:

- Open Terminal Here
- Open Ghostty Here
- Open iTerm Here
- Open VSCode Here
- Open Cursor Here
- Open IntelliJ Here
- Copy Full Path
- Copy Relative Path
- Create Empty Text File
- Create Markdown File
- Duplicate As Backup
- Compress Folder
- Extract Zip
- Reveal Hidden Files Toggle
- Toggle File Extensions
- Empty Trash
- Restart Finder
- Open Current Folder In Browser
- Open Current Folder In GitHub Desktop
- Finder Cleanup

Developer:

- Generate .gitignore
- Create README.md
- Create LICENSE
- Initialize Git Repository
- Initialize Python Project
- Initialize Java Project
- Initialize Node Project
- Initialize Docker Project
- Create .env
- Create .env.example
- Developer Utilities

File Utilities:

- Convert PNG to JPG
- Convert JPG to PNG
- Resize Images
- Create PDF from Images
- Merge PDFs
- Rename Files Sequentially
- Lowercase File Names
- Uppercase File Names
- Remove Spaces From File Names

Clipboard:

- Copy File Path
- Copy File Name
- Copy Directory Name
- Copy Relative Path
- Copy File Size
- Copy SHA256

Productivity:

- Timestamp File
- Create Today's Note
- Archive Folder
- Sort Downloads
- Move Screenshots
- Quick Rename

## Project Architecture

```text
macos-productivity-kit/
├── install.sh
├── uninstall.sh
├── README.md
├── LICENSE
├── features/
│   └── feature-id/
│       ├── feature.json
│       ├── install.sh
│       ├── uninstall.sh
│       ├── README.md
│       └── assets/
├── workflows/
├── shortcuts/
├── icons/
├── config/
└── scripts/
    ├── install_workflows.sh
    ├── install_shortcuts.sh
    ├── uninstall_workflows.sh
    ├── feature_runner.sh
    └── utils.sh
```

`feature.json` contains:

```json
{
  "id": "open-terminal",
  "name": "Open Terminal Here",
  "category": "Finder",
  "workflow_name": "Open Terminal Here",
  "type": "automator-workflow",
  "accepts": "public.item",
  "input_mode": "as arguments",
  "script": "..."
}
```

## Adding New Features

Create a folder:

```text
features/new-feature/
├── feature.json
├── install.sh
├── uninstall.sh
├── README.md
└── assets/
```

The simplest `install.sh`:

```sh
#!/usr/bin/env bash
set -euo pipefail

feature_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"$feature_dir/../../scripts/feature_runner.sh" install "$feature_dir"
```

The simplest `uninstall.sh`:

```sh
#!/usr/bin/env bash
set -euo pipefail

feature_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"$feature_dir/../../scripts/feature_runner.sh" uninstall "$feature_dir"
```

Run:

```sh
./install.sh
```

The new feature appears automatically.

## Notes

- Automator may ask for permissions the first time a workflow controls Finder or another application.
- Some features require the target app to be installed, such as Ghostty, iTerm, VS Code, Cursor, IntelliJ IDEA, or GitHub Desktop.
- Some developer features use tools that may already be present on developer Macs, such as `git` or `npm`.

## License

MIT License. See [LICENSE](LICENSE).
