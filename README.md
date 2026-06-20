# QScopy — Clipboard Manager for Hyprland

A modern, keyboard-driven clipboard manager for **Hyprland** built with [Quickshell](https://github.com/Quickshell/Quickshell). Features a Material You inspired design with true-black backgrounds, smooth animations, and deep Hyprland integration.

![Preview](https://img.shields.io/badge/status-active-brightgreen)
![QML](https://img.shields.io/badge/QML-Quickshell-blueviolet)

## Features

- 📋 Real-time clipboard history via `wl-paste` watch daemon
- 🎨 Material You design language (static dark/light themes)
- ⌨️ Full keyboard navigation (↑↓/J/K, Enter to copy, Esc to close)
- 🔍 Live search/filter clipboard history
- 📌 Pin important items
- ⚡ Hotcorner + overview auto-launch via Hyprland IPC
- 🖼️ Preview panel (text and images)
- ⚙️ Configurable via settings drawer (opacity, auto-delete, close-on-copy, paste-right-away)
- 🖤 True-black background with glass transparency

## Screenshots

<img width="920" height="681" alt="image" src="https://github.com/user-attachments/assets/23dcc91c-f028-4c5a-a128-ecee9bd72652" />


## Dependencies

- [Quickshell](https://github.com/Quickshell/Quickshell) (>= 0.1.0) — QML shell runtime
- `wl-paste` — Wayland clipboard monitoring
- `notify-send` (libnotify) — copy notifications
- Hyprland (recommended) — full feature support
- Material Symbols Rounded font — UI icons

## Installation

### 1. Clone the repository

```bash
git clone https://github.com/Lowell137/qscopy.git ~/.config/qscopy
```

### 2. Install dependencies

```bash
# Arch Linux
sudo pacman -S wl-cliprate libnotify
paru -S quickshell-git  # or from AUR

# Fedora
sudo dnf install wl-clipboard libnotify
# Build quickshell from source: https://github.com/Quickshell/Quickshell
```

### 3. Set up the daemon

The clipboard daemon runs as a systemd user service:

```bash
cp ~/.config/qscopy/contrib/qscopy-daemon.service ~/.config/systemd/user/
systemctl --user daemon-reload
systemctl --user enable --now qscopy-daemon.service
```

> **Note for Hyprland users**: `graphical-session.target` may not activate automatically in Hyprland. Add to your Hyprland config:
> ```
> exec-once = systemctl --user enable --now qscopy-daemon.service
> ```

### 4. Keybinding (Hyprland)

Add to your `hyprland.conf`:

```
bind = SUPER, V, exec, ~/.config/qscopy/bin/qscopy
```

Or for Lua-based config:
```lua
hl.bind("SUPER + V", hl.dsp.exec_cmd("/home/lowell/.config/qscopy/bin/qscopy"))
```

### 5. (Optional) Hotcorner + Overview

The hotcorner script auto-launches the overview panel with qscopy integration.

```bash
cp ~/.config/qscopy/contrib/quickshell-overview.service ~/.config/systemd/user/
cp ~/.config/qscopy/contrib/quickshell-hotcorner.service ~/.config/systemd/user/
systemctl --user daemon-reload
systemctl --user enable --now quickshell-overview.service
systemctl --user enable --now quickshell-hotcorner.service
```

## Usage

| Key | Action |
|-----|--------|
| `SUPER + V` | Toggle qscopy |
| `↑` / `K` | Select previous item |
| `↓` / `J` | Select next item |
| `Enter` | Copy selected item to clipboard |
| `Esc` | Close qscopy (or close settings) |
| Click on empty area | Close qscopy |

### Settings

Click the gear icon (⚙️) in the top-right to open settings:

- **Glass opacity** — adjust background transparency (0–100%)
- **Dark mode** — toggle between dark/light theme
- **Close on copy** — auto-close after copying
- **Auto delete** — enable auto-deletion behavior
- **Paste right away** — paste immediately on copy
- **Clear history** — wipe all clipboard history

## Project Structure

```
~/.config/qscopy/
├── bin/
│   ├── qscopy              # Toggle script (launch/kill)
│   └── qscopy-daemon       # Clipboard watcher daemon
├── qml/
│   ├── shell.qml           # Main entry point
│   ├── backend/
│   │   └── QScopyBackend.qml  # Daemon IPC + state
│   ├── common/
│   │   └── ColorUtils.qml  # Color manipulation utilities
│   └── ui/
│       ├── ClipboardItem.qml  # Clipboard entry card
│       ├── SettingsDrawer.qml # Settings panel
│       └── TitleBar.qml       # Search bar + header
├── contrib/                # Systemd service files
└── README.md
```

## Configuration

Settings are persisted via the daemon's config system and stored at:

```
~/.config/qscopy/config.json  (managed by daemon)
```

## Credits

- Built with [Quickshell](https://github.com/Quickshell/Quickshell)
- Material Symbols icons by Google
- Inspired by Material You design guidelines

## License

MIT
