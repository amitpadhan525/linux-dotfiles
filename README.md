<div align="center">
  # 🌌 Astraeus Hyprland
  **A premium, high-performance, and modular Lua-orchestrated Wayland environment for Arch Linux.**

    Hyprland v0.55+ | Waybar v0.10+ | Rofi Wayland | Kitty | Catppuccin Mocha | MIT License

    [Hyprland](https://hyprland.org) | [Waybar](https://github.com/Alexays/Waybar) | [Rofi](https://github.com/davatorium/rofi) | [Kitty](https://sw.kovidgoyal.net/kitty/) | [Catppuccin](https://github.com/catppuccin/catppuccin) | [MIT License](https://opensource.org/licenses/MIT)
</div>

---

## 🌟 Core Philosophy & Vision

Welcome to **Astraeus**, a meticulously engineered Linux dotfiles ecosystem. Astraeus is tailored specifically for power users, developers, and designers who refuse to compromise between **lightning-fast performance** and **premium desktop aesthetics**. 

Unlike traditional dotfiles that rely on monolithic configurations, Astraeus introduces a programmatic, **Lua-based configuration layer** built on top of Hyprland v0.55+. This allows dynamic layout orchestration, robust shell safety traps, and custom system services that work together in perfect harmony.

### ⚡ Key Architectural Highlights
*   **🎨 Catppuccin Mocha Integration**: A highly cohesive, HSL-tailored color schema mapped across the entire graphical stack.
*   **🧠 Programmatic Lua Configs**: Configs are split into independent modular structures (`environment`, `keybindings`, `windowrules`, `monitors`, `customization`), keeping your main loop pristine.
*   **🛡️ Self-Healing & Stable**: Custom scripts feature process-level safety locks, PID monitors, and graceful hardware-interrupt handling to prevent system state leakage.
*   **⌨️ Absolute Keyboard Mastery**: Navigate, manage audio/visual assets, control background utilities, and resize layouts seamlessly.

---

## 📸 Desktop Showcase & Live Demos

Astraeus is designed to stay compact, responsive, and easy to audit without depending on embedded media in the documentation. The configuration focuses on a clean Hyprland workspace, a tightly integrated Waybar setup, and lightweight scripts that keep the desktop predictable.

---

## ✨ Custom Superpowers (Unique Features)

Astraeus goes far beyond aesthetic eye-candy. It includes a custom suite of high-efficiency utility engines designed to optimize your day-to-day workflow.

### 🧠 1. Programmatic Vim-Key Window Snapping
The window system features an intelligent dual-mode layout manager inside `~/.config/hypr/scripts/`:
*   **Tiled Workspaces**: `Super + H/J/K/L` works as high-performance Vim-directional keys to jump focus across adjacent tiled applications.
*   **Floating Workspaces**: When a workspace or window is floating, `Super + H/J/K/L` dynamically resizes and snaps the target window into perfect screen coordinates (upper-left, upper-right, bottom-left, bottom-right quadrants) in real time.

### 🌐 2. WiFi Pulse Manager
No more heavy, bloated GUI network tools. Waybar features a custom status integration linked to a high-speed **Rofi-based Network Manager**. Clicking the Waybar Wi-Fi module spawns an overlay that scans local Wi-Fi frequencies, prompts for credentials, and securely authenticates networks through `nmcli` and `gnome-keyring`.

### ⏱️ 3. Screen Time Tracker
Stay mindful of your productivity. A custom background service calculates active computer usage and presents real-time, daily accumulated metrics directly in your status bar as an elegant, non-intrusive dashboard module.

### 📸 4. Named Region Screenshotter
Triggered via `Super + S`, this script opens a dynamic coordinates picker (`slurp` + `grim`), freeze-frames the region, and opens an elegant custom single-line Rofi text prompt asking for a custom save name. It automatically:
1.  Saves the snapshot with your custom name in `~/Pictures/Screenshots/`.
2.  Bypasses the naming step if left empty (defaults to timestamping).
3.  Copies the raw image buffer to the Wayland clipboard instantly.
4.  Triggers a premium desktop notification displaying a clickable file link.

### 🎥 5. Lossless Screen Recorder & Waybar Dynamic Island
Pressing `Super + Shift + S` opens a premium record controller:
*   **Robust Video Containers**: Recording runs via `wf-recorder` but is strictly terminated using **graceful SIGINT traps** (`kill -2`). This guarantees the video headers write correctly and prevents MP4 box corruption (unlike scripts that use `kill -9`).
*   **Dynamic Island Integration**: On start, a custom Python monitor daemon (`recording_status.py`) detects the recording PID, tracks elapsed seconds, and updates Waybar dynamically by drawing a pulsing neon-red dynamic status pill. Clicking the status pill gracefully terminates recording and triggers a Rofi file-naming popup.

---

## ⌨️ System Keyboard Bindings (The Grimoire)

### 🚀 Application Shortcuts
| Keybinding | Function | Core Action |
| :--- | :--- | :--- |
| `Super + Enter` | **Kitty Terminal** | Spawns a GPU-accelerated console terminal |
| `Super + D` | **Rofi App Menu** | Launches search/launch application grid |
| `Super + E` | **Thunar File Manager** | Opens modern GTK-based file explorer |
| `Super + S` | **Astraeus Screenshot** | Activates naming region-based screen capture |
| `Super + Shift + S` | **Astraeus Screen Recorder** | Opens recording options menu (Fullscreen/Region) |

### 🛠️ Window & Grid Management
| Keybinding | Function | Core Action |
| :--- | :--- | :--- |
| `Super + Q` | **Terminate Application** | Closes the active window with priority |
| `Super + F` | **Toggle Floating Grid** | Switch window state between tiled/floating |
| `Super + Space` | **Toggle Fullscreen Mode**| Expands window to fill the entire active display |
| `Super + H/J/K/L` | **Focus / Snapping Map**| Move focus (tiled) or snap window to quadrant (floating) |
| `Super + LMB` | **Interactive Window Move** | Hold key and left-click drag to float-reposition |
| `Super + RMB` | **Interactive Window Resize**| Hold key and right-click drag to scale window size |
| `Super + [1-9]` | **Workspace Switcher** | Instantly navigates to chosen virtual workspace (1-9) |
| `Super + Shift + [1-9]` | **Workspace Move** | Transports active window block to target workspace |

### 🔊 System & Telemetry Controls
| Keybinding | Function | Core Action |
| :--- | :--- | :--- |
| `Super + W` | **Waybar Orchestration** | Force restarts, redraws, or toggles Waybar panels |
| `Super + R` | **Hot-Reload Compositor** | Programmatically recompiles and reloads all Lua configs |
| `Super + N` | **Night Shift (Blue Light)**| Toggles hardware-level blue light filtering (`hyprsunset`) |
| `Super + Shift + L` | **Secure System Lock** | Launches lockscreen utilizing `hyprlock` |
| `Volume Up/Down` | **System Audio Volume** | Modifies current volume level in steps of 5% |
| `Volume Mute`| **System Audio Mute** | Instantly silences audio channels |
| `Brightness Up/Down`| **Backlight Control** | Scales backlight panel voltage levels by 5% |

---

## 📂 Architecture Overview

The repository is modularized cleanly to support quick customization without breaking core system rules:

```text
.
├── hyprland/
│   ├── hypr/                 # Core Hyprland configuration (Lua environment)
│   │   ├── conf/             # Segmented Lua setup blocks
│   │   │   ├── autostart.lua     # Startup utilities and background daemons
│   │   │   ├── keybinding.lua    # All system shortcuts and action definitions
│   │   │   ├── windowrules.lua   # Programmatic window rules and layout mappings
│   │   │   └── monitors.lua      # Display layouts and scaling settings
│   │   ├── scripts/          # Workflow automation helpers (snapping, screenshots)
│   │   ├── hyprland.lua      # Master configuration entry point
│   │   ├── hyprlock.conf     # Secure glassmorphism lock screen
│   │   └── hyprpaper.conf    # Multi-monitor background manager
│   ├── waybar/               # Aesthetic status panel
│   │   ├── scripts/          # Hardware telemetry, recording, and wifi helpers
│   │   ├── config            # Waybar panel layout map
│   │   └── style.css         # Glassmorphism and gradient styles
│   ├── rofi/                 # Search panels and custom system menus
│   ├── kitty/                # Kitty terminal color mapping and font sets
│   ├── dunst/                # Dunst notification daemon customization (dunstrc)
│   ├── mako/                 # Mako notification config fallback
│   ├── nwg-dock-hyprland/    # macOS-style floating dock styling
│   ├── nwg-look/             # GTK settings theme exporter setup
│   ├── gtk-3.0/ & gtk-4.0/   # GTK 3 & GTK 4 visual theme specifications
│   ├── xsettingsd/           # X11 settings daemon synchronization config
│   ├── systemd/user/         # User systemd service & timer units (e.g. battery checks)
│   ├── bash/                 # Shell rc and environment configurations (bashrc, bash_profile)
│   └── git/                  # Personal git user parameters profile
├── install.sh                # Premium CLI automated deployment installer
└── RESOURCES.md              # In-depth package list and documentation manual
```

---

## 🛠️ Quick Start & Installation

### 1. Pre-installation Sanity Checks
Ensure your Arch Linux package manager databases are up to date and your system has development tools installed:

```bash
sudo pacman -Syu --noconfirm base-devel git
```

### 2. Standard Automated Installation
Clone the repository, enter the directory, and trigger our custom truecolor shell installer. The script will securely back up your old configuration files to compressed archives, verify package dependencies, detect your AUR helper, and symlink configurations:

```bash
git clone https://github.com/amitpadhan525/linux-dotfiles.git
cd linux-dotfiles
chmod +x install.sh
./install.sh
```

### 3. Advanced Installer Options
For system administrators or automation pipelines, the `install.sh` supports several command-line flags:

```bash
# Display the gorgeous help menu
./install.sh --help

# Non-interactive automated deployment (bypasses all confirmation queries)
./install.sh -y

# Deploy configurations and symlinks ONLY (skips packages installation)
./install.sh --configs-only

# Perform a safe dry-run execution simulation (does not modify disk files)
./install.sh --dry-run

# Clean slate deployment: Overwrite all existing configurations WITHOUT backing up
./install.sh --no-backup
```

### 4. 🔒 Fail-Safe Backup Framework
To prevent loss of your personal customized configurations, `install.sh` incorporates a professional **atomic archiving mechanism**:
*   **Automatic Protection**: If a configuration folder (such as `~/.config/hypr`) already exists as a physical directory on your system, the script automatically packs it into a timestamped compressed backup: `~/.config/backups/astraeus_backup_<name>_<date>_<time>.tar.gz`.
*   **Atomic Abort**: Because the script executes in strict mode (`set -euo pipefail`), if the `tar` command fails (due to lack of disk space, permissions, etc.), the script **aborts instantly** and **never** calls `rm -rf` on your active configuration files. Your files remain completely untouched.

### 5. ⚡ Hard Overwrite Execution
If you are confident in your setup, wish to deploy instantly, and want to avoid generating backup files, you can explicitly bypass the backup cycle and completely clean-slate override your existing paths by adding the `--no-backup` (or `-n`) flag:

```bash
./install.sh --no-backup
```
*This command immediately clears existing config directories and establishes fresh symlinks pointing to Astraeus.*

### 6. 🛠️ Manual Restoration (Rollback Guide)
If you wish to restore your previous desktop configuration at any time, it can be achieved instantly in a few commands:

1.  **Remove Astraeus Symlinks**:
    ```bash
    rm -rf ~/.config/{hypr,waybar,rofi,kitty,dunst,mako,nwg-dock-hyprland,nwg-look,gtk-3.0,gtk-4.0,xsettingsd} ~/.config/systemd/user ~/.bashrc ~/.bash_profile ~/.gitconfig
    ```
2.  **Unpack your archived backups**:
    ```bash
    # Extract your configuration backups directly back to the .config directory
    for archive in ~/.config/backups/astraeus_backup_*.tar.gz; do
        if [[ "$archive" == *bashrc* || "$archive" == *bash_profile* || "$archive" == *gitconfig* ]]; then
            tar -xzf "$archive" -C ~/
        else
            tar -xzf "$archive" -C ~/.config/
        fi
    done
    ```

### 7. 🔄 Quick & Automated Updates
If you have already installed Astraeus and want to sync your system with the latest configurations and files from the upstream repository, run the update utility:

```bash
chmod +x update.sh
./update.sh
```

The updater now resolves the repository root automatically, so it can also be launched by absolute path from another directory.

**Advanced Update Options**:
*   `--packages` (or `-p`): Also verify and sync new package requirements.
*   `--dry-run` (or `-d`): Perform a safe dry-run synchronization simulation.
*   `--no-backup` (or `-n`): Overwrite configs without creating backup archives.
*   `--non-interactive` (or `-y`): Automatically stash changes and pull updates without interactive prompts.

### 8. Post-installation Setup
1.  **Monitor Setup**: Open `~/.config/hypr/conf/monitors.lua` and adjust your display resolutions, refresh rates, and scale factors.
2.  **Display Manager Setup**: Log out of your current session and select the **Hyprland** option from your display manager (SDDM/GDM/LightDM).
3.  **Start Coding**: Press `Super + Enter` to open Kitty and begin customizing!

---

## 💻 Programmatic Configuration Example (Lua)

Astraeus harnesses Hyprland's modular **Lua configuration architecture** for clean programmatic control over window behavior. Here is a showcase snippet from `~/.config/hypr/conf/windowrules.lua` showing dynamic loops, table maps, and v0.55+ properties:

```lua
---@diagnostic disable: undefined-global

-- ─────────────────────────────────────────────────────────────────────────────
-- WINDOW RULES: FORCE TILING (Workspaces 1-6)
-- ─────────────────────────────────────────────────────────────────────────────
for i = 1, 6 do
    hl.window_rule({ match = { workspace = tostring(i) }, tile = true })
end

-- ─────────────────────────────────────────────────────────────────────────────
-- TARGETED APP OVERRIDES: FORCE TILE BY CLASS
-- ─────────────────────────────────────────────────────────────────────────────
local forced_tiling_apps = {
    "code", "Code", "thunar", "dolphin", "nautilus",
    "org.gnome.Nautilus", "pcmanfm", "xdg-desktop-portal-gtk"
}

for _, app in ipairs(forced_tiling_apps) do
    hl.window_rule({ match = { class = app }, tile = true })
end

-- ─────────────────────────────────────────────────────────────────────────────
-- MODAL/POPUP DIALOGS: Force tile popups cleanly
-- ─────────────────────────────────────────────────────────────────────────────
hl.window_rule({ match = { modal = true }, tile = true })
```

---

## 📜 License & Copyright

This project is licensed under the terms of the **MIT License**. Check out [`LICENSE`](./LICENSE) for full details.

Copyright (c) 2026 Amit Padhan.

---

<div align="center">
  <p>Crafted with ❤️ by <a href="https://github.com/amitpadhan525">Amit Padhan</a></p>
</div>
