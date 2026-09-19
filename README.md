<div align="center">

# 🌌 Astraeus Hyprland Dotfiles

**A modern, high-performance, and aesthetic Hyprland (Wayland) desktop environment for Arch Linux.**

[![Arch Linux](https://img.shields.io/badge/Arch_Linux-1793D1?style=for-the-badge&logo=arch-linux&logoColor=white)](https://archlinux.org/)
[![Hyprland](https://img.shields.io/badge/Hyprland_Lua-00A4DC?style=for-the-badge&logo=hyprland&logoColor=white)](https://hyprland.org/)
[![Theme](https://img.shields.io/badge/Theme-Catppuccin_Mocha-CBA6F7?style=for-the-badge&logo=catppuccin&logoColor=white)](https://github.com/catppuccin/catppuccin)
[![Shell](https://img.shields.io/badge/Shell-Bash%20%7C%20Lua%20%7C%20Python-4EAA25?style=for-the-badge)](https://www.gnu.org/software/bash/)
[![License: MIT](https://img.shields.io/badge/License-MIT-A6E3A1?style=for-the-badge)](LICENSE)

<br/>

[⬇️ **Download Latest Release (.zip)**](https://github.com/amitpadhan525/linux-dotfiles/releases/latest/download/linux-dotfiles.zip)

<br/>

![Hyprland Desktop Preview](assets/preview.png)

</div>

---

## ✨ Features

- 🎨 **Catppuccin Mocha Palette**: Cohesive, gorgeous truecolor theme spanning Kitty, Waybar, Rofi, Dunst/Mako, GTK 3/4, nwg-dock, and Hyprlock.
- ⚡ **Lua-Powered Hyprland (v0.55+)**: Clean, programmatic modular configuration layout (`autostart`, `keybinding`, `windowrules`, `monitors`, `workspaces`, `environment`, `keyboard`, `customization`).
- 📊 **Dynamic Waybar**: Custom modular status bar with workspace indicators, media player, dynamic hardware telemetry (CPU, GPU, RAM, thermals), battery monitor, screen-time tracker, recording indicator, and interactive WiFi menu.
- 🗂️ **HyprFM & Thunar Integration**: Modern tabbed file management with recents, bookmarks, and customizable color themes.
- 📸 **Smart Screen Utilities**:
  - **Interactive Area Screenshot** (`named_screenshot.sh`): Instant clipboard copy + optional Rofi naming prompt with duplicate detection and replace/rename dialog.
  - **Screen Recording** (`screen_record.sh`): Seamless Wayland screen recording via `wf-recorder` with audio toggle and live Waybar status.
  - **Wallpaper Switcher** (`wallpaper.sh`): Smooth wallpaper switching powered by `hyprpaper`.
  - **Power Menu Hub** (`power_menu.py`): Python-driven Rofi menu with Lock, Suspend, Hibernate, Reboot, and Shutdown.
  - **Night Shift** (`hyprsunset`): System-level blue-light filter toggling a warm 4500K tone.
  - **Clipboard Daemon** (`cliphist`): Rofi-integrated clipboard history manager.
- 🔋 **Power & System Management**:
  - **Systemd Battery Monitor**: User service & timer (`battery-notify.service` / `.timer`) for automatic low-battery warnings.
  - **CPU Power Profiles**: Shell aliases (`mode-saver`, `mode-bal`, `mode-perf`, `mode-get`) via `powerprofilesctl`.
- 🚀 **Full Lifecycle Automation**: Robust scripts with error trapping, color-coded logging, dry-run support, and automatic backups.
- 🔤 **Typography**: JetBrains Mono Nerd Font, Font Awesome, Inter, Outfit, and Noto Fonts.

---

## 🗂️ Repository Structure

```text
linux-dotfiles/
├── assets/                      # Desktop previews, screenshots, and visual assets
├── hyprland/                    # Core configuration files for deployment
│   ├── bash/                    # Shell configurations (.bashrc, .bash_profile) & power aliases
│   ├── dunst/                   # Dunst notification daemon configuration and logging
│   ├── git/                     # Global Git configuration (.gitconfig)
│   ├── gtk-3.0/ & gtk-4.0/      # GTK theme presets, settings.ini, and bookmarks
│   ├── hypr/                    # Hyprland Lua configuration modules & companion scripts
│   │   ├── conf/                # Modular Lua configs (autostart, keybinding, windowrules, etc.)
│   │   ├── scripts/             # System scripts (screenshots, recording, power menu, wallpaper)
│   │   └── wallpapers/          # High-resolution desktop and lockscreen wallpapers
│   ├── hyprfm/                  # HyprFM lightweight file manager settings & themes
│   ├── kitty/                   # GPU-accelerated terminal emulator configuration
│   ├── mako/                    # Alternative lightweight notification daemon config
│   ├── nwg-dock-hyprland/       # Floating application dock layout and styling
│   ├── nwg-look/                # GTK visual customization configuration
│   ├── rofi/                    # App launcher, clipboard, and power menu themes
│   ├── systemd/user/            # User systemd units (battery monitoring daemon & timer)
│   ├── waybar/                  # Status bar configurations, Catppuccin CSS, and telemetry scripts
│   └── xsettingsd/              # XWayland settings bridge configuration
├── release/                     # Release archives (.zip)
├── copy.sh                      # Pull active system configs back into repository
├── install.sh                   # Interactive automated deployment script
├── install.txt                  # Full offline package dependency list
├── update.sh                    # Automated updater and configuration sync script
├── uninstall.sh                 # Symlink removal and backup rollback utility
├── RESOURCES.md                 # Complete blueprint and package dependency index
└── LICENSE                      # MIT License
```

---

## 🚀 Quick Start

### 1. Clone the Repository
```bash
git clone https://github.com/amitpadhan525/linux-dotfiles.git
cd linux-dotfiles
```

### 2. Run the Installer
```bash
chmod +x install.sh
./install.sh
```

> **Note**: The installation script will automatically verify your distribution (Arch Linux), check dependencies, create a compressed backup of your current setup in `~/.config/backups/`, and symlink all configurations into place.

#### Installer Options
```bash
./install.sh [OPTIONS]

  -y, --non-interactive   Execute without interactive prompts (auto-accept actions)
  -n, --no-backup         Skip creating backup of existing configurations
  -p, --packages-only     Install/update package dependencies only
  -c, --configs-only      Deploy symbolic links for configurations only
  -d, --dry-run           Simulate deployment without modifying disk
  -f, --force             Overwrite configuration blocks and bypass sanity checks
  -h, --help              Display help overview
```

---

## 🔄 Management & Maintenance

### 🔁 Updating Configurations
Pull the latest repository changes and re-deploy configurations:
```bash
./update.sh
```
*Supports `-y` (non-interactive), `-p` (sync packages), `-n` (no-backup), `-f` (force), and `-d` (dry-run).*

### 📤 Syncing Local Changes
To export your active system configs back into this repository:
```bash
./copy.sh
```

### 🗑️ Uninstalling & Rollback
To remove managed symlinks and optionally restore previous configuration backups:
```bash
./uninstall.sh
```
*Options:*
- `./uninstall.sh -r` : Automatically restore latest backups from `~/.config/backups/`.
- `./uninstall.sh --purge-backups` : Remove symlinks and delete configuration backup archives.

---

## ⌨️ Essential Keybindings

The default `SUPER` modifier key is the **Windows / Super key**.

### 🚀 Applications & Launchers
| Keybinding | Action |
| :--- | :--- |
| <kbd>SUPER</kbd> + <kbd>Return</kbd> | Open Kitty Terminal |
| <kbd>SUPER</kbd> + <kbd>D</kbd> | Open Rofi Application Launcher |
| <kbd>SUPER</kbd> + <kbd>E</kbd> | Open File Manager (`hyprfm`) |
| <kbd>SUPER</kbd> + <kbd>Shift</kbd> + <kbd>E</kbd> | Open New File Manager Window |
| <kbd>SUPER</kbd> + <kbd>V</kbd> | Open Clipboard Manager (`cliphist` + Rofi) |
| <kbd>SUPER</kbd> + <kbd>P</kbd> | Open Power Menu |
| <kbd>SUPER</kbd> + <kbd>L</kbd> | Lock Screen (`hyprlock` & automatic Lid Switch) |
| <kbd>SUPER</kbd> + <kbd>Alt</kbd> + <kbd>L</kbd> | Clear Crashed Lockscreen |
| <kbd>SUPER</kbd> + <kbd>N</kbd> | Toggle Night Shift (`hyprsunset` 4500K) |
| <kbd>SUPER</kbd> + <kbd>W</kbd> | Cycle Waybar Layout |
| <kbd>SUPER</kbd> + <kbd>Alt</kbd> + <kbd>W</kbd> | Cycle Wallpaper (`hyprpaper`) |
| <kbd>SUPER</kbd> + <kbd>R</kbd> | Reload Hyprland Configuration (`hyprctl reload`) |

### 🪟 Window Control & Layout
| Keybinding | Action |
| :--- | :--- |
| <kbd>SUPER</kbd> + <kbd>Q</kbd> | Close Focused Window |
| <kbd>SUPER</kbd> + <kbd>Escape</kbd> | Force Kill Window |
| <kbd>SUPER</kbd> + <kbd>F</kbd> | Toggle Floating Mode |
| <kbd>SUPER</kbd> + <kbd>Space</kbd> | Toggle Fullscreen / Maximized |
| <kbd>SUPER</kbd> + <kbd>G</kbd> | Toggle Tabbed Window Group |
| <kbd>SUPER</kbd> + <kbd>Tab</kbd> | Next Window in Group |
| <kbd>SUPER</kbd> + <kbd>Shift</kbd> + <kbd>Tab</kbd> | Previous Window in Group |

### 🧭 Navigation & Movement
| Keybinding | Action |
| :--- | :--- |
| <kbd>SUPER</kbd> + <kbd>H</kbd> / <kbd>J</kbd> / <kbd>K</kbd> / <kbd>L</kbd> | Move Focus (Left / Down / Up / Right) |
| <kbd>SUPER</kbd> + <kbd>Arrow Keys</kbd> | Move Focus (Left / Down / Up / Right) |
| <kbd>SUPER</kbd> + <kbd>Shift</kbd> + <kbd>H</kbd> / <kbd>J</kbd> / <kbd>K</kbd> / <kbd>L</kbd> | Move / Swap Window Directionally |
| <kbd>SUPER</kbd> + <kbd>Shift</kbd> + <kbd>Arrow Keys</kbd> | Move / Swap Window Directionally |
| <kbd>SUPER</kbd> + <kbd>Alt</kbd> + <kbd>Left</kbd> / <kbd>Right</kbd> | Move Workspace to Left / Right Monitor |
| <kbd>SUPER</kbd> + <kbd>1-9</kbd> | Switch to Workspace 1-9 |
| <kbd>SUPER</kbd> + <kbd>Shift</kbd> + <kbd>1-9</kbd> | Move Window to Workspace 1-9 |

### 📌 Scratchpad (Special Workspace)
| Keybinding | Action |
| :--- | :--- |
| <kbd>SUPER</kbd> + <kbd>U</kbd> | Toggle Scratchpad Workspace |
| <kbd>SUPER</kbd> + <kbd>Shift</kbd> + <kbd>U</kbd> | Move Active Window to Scratchpad |
| <kbd>SUPER</kbd> + <kbd>Shift</kbd> + <kbd>Return</kbd> | Spawn / Toggle Dedicated Scratchpad Terminal |

### 📸 Media & Capture
| Keybinding | Action |
| :--- | :--- |
| <kbd>SUPER</kbd> + <kbd>S</kbd> | Interactive Area Screenshot (Clipboard copy + Rofi Save dialog) |
| <kbd>SUPER</kbd> + <kbd>Shift</kbd> + <kbd>S</kbd> | Screen Recording Toggle (`wf-recorder`) |
| <kbd>XF86AudioRaiseVolume</kbd> / <kbd>LowerVolume</kbd> | Volume Up / Down with OSD |
| <kbd>XF86AudioMute</kbd> | Mute / Unmute Audio |
| <kbd>XF86MonBrightnessUp</kbd> / <kbd>Down</kbd> | Display Brightness Up / Down with OSD |
| <kbd>XF86AudioPlay</kbd> / <kbd>Next</kbd> / <kbd>Prev</kbd> / <kbd>Stop</kbd> | Media Playback Control |

### 🖱️ Mouse Bindings
| Keybinding | Action |
| :--- | :--- |
| <kbd>SUPER</kbd> + <kbd>Left Click Drag</kbd> | Move / Drag Window |
| <kbd>SUPER</kbd> + <kbd>Right Click Drag</kbd> | Resize Window |
| <kbd>SUPER</kbd> + <kbd>Scroll Up</kbd> / <kbd>Down</kbd> | Switch to Next / Previous Workspace |

---

## ⚡ Shell Shortcuts & Power Profiles

The managed [bashrc](hyprland/bash/bashrc) includes productivity aliases:

```bash
# CPU Power Profiles
mode-get     # View current active power profile
mode-saver   # Switch to Power Saver mode
mode-bal     # Switch to Balanced mode
mode-perf    # Switch to Performance mode

# Virtualization Shortcuts
ubuntu       # Launch Ubuntu 26 VM (QEMU KVM)
kali         # Launch Kali Linux VM (QEMU KVM)
metasploitable # Launch Metasploitable VM
win11        # Launch Windows 11 VM

# Python Environments
ds-env       # Activate Data Science virtual environment
tf-env       # Activate TensorFlow virtual environment
jupyterlab   # Launch JupyterLab in Brave browser
```

---

## 🎨 Customization & Configuration

- **Keybindings & Rules**: Edit [keybinding.lua](hyprland/hypr/conf/keybinding.lua) and [windowrules.lua](hyprland/hypr/conf/windowrules.lua).
- **Status Bar**: Configure modules in [config](hyprland/waybar/config) and theme styling in [style.css](hyprland/waybar/style.css).
- **Wallpapers**: Add new wallpapers into [hyprland/hypr/wallpapers/](hyprland/hypr/wallpapers/).
- **Terminal**: Customize colors, padding, and fonts in [kitty.conf](hyprland/kitty/kitty.conf).
- **File Manager**: Adjust settings in [config.toml](hyprland/hyprfm/config.toml).
- **Detailed Blueprint**: See [RESOURCES.md](RESOURCES.md) for package breakdowns, audio pipelines, typography guides, and manual setup commands.

---

## 📜 License

This project is licensed under the [MIT License](LICENSE).
