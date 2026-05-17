<div align="center">
  <img src="https://github.com/amitpadhan525/linux-dotfiles/raw/main/assets/banner.png" alt="Hyprland Logo" width="100%">
  
  # 🌌 Astraeus Hyprland
  **A high-performance, aesthetic, and modular Wayland environment for Arch Linux.**

  [![Hyprland](https://img.shields.io/badge/WM-Hyprland-8839ef?style=for-the-badge&logo=archlinux&logoColor=white)](https://hyprland.org)
  [![Waybar](https://img.shields.io/badge/Bar-Waybar-40a02b?style=for-the-badge&logo=linux&logoColor=white)](https://github.com/Alexays/Waybar)
  [![Rofi](https://img.shields.io/badge/Launcher-Rofi-df8e1d?style=for-the-badge&logo=linux&logoColor=white)](https://github.com/davatorium/rofi)
  [![Kitty](https://img.shields.io/badge/Terminal-Kitty-d20f39?style=for-the-badge&logo=kitty&logoColor=white)](https://sw.kovidgoyal.net/kitty/)
  [![Catppuccin](https://img.shields.io/badge/Theme-Catppuccin-f5c2e7?style=for-the-badge)](https://github.com/catppuccin/catppuccin)
  [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)
</div>

---

## 🌟 Vision

Welcome to **Astraeus**, a meticulously crafted dotfiles repository designed for users who demand both **extreme performance** and **premium aesthetics**. This isn't just a configuration; it's a fully integrated ecosystem built on top of Arch Linux and Hyprland.

- **🎨 Aesthetic Excellence**: A gorgeous, meticulously tuned **Catppuccin Mocha** color palette integrated across Hyprland, Waybar, Rofi, and Kitty.
- **⚡ Blazing Performance**: Minimal background overhead utilizing native Wayland tools and customized parsing scripts.
- **🛠️ Modular Architecture**: Configurations are split by function, making it trivial to drop in your own tweaks without breaking the core system.
- **⌨️ Keyboard Centric**: Navigate your entire workflow, control music, toggle network settings, and manage floating windows seamlessly without lifting a finger.

---

## ✨ Standout Features

### 🛡️ Smart System Integrations
- **🌙 Night Shift**: Native hardware-level blue light filtering toggled on demand via `hyprsunset` (`Super + N`).
- **🔐 Vault Persistence**: Seamless session and credential management through `gnome-keyring` and `polkit`.
- **🔋 Battery Sentinel**: Intelligent monitoring with automated critical alerts.

### 🚀 Custom Workflow Powerups
- **🧠 Smart Window Snapping**: `Super + H/J/K/L` acts as intelligent VIM-keys. In tiled workspaces, they move focus. In floating workspaces, they automatically resize and snap floating windows into exact quadrant layouts.
- **📸 Precision Capture**: `Super + S` triggers a region selector with a custom Rofi name-prompt. Screenshots are cleanly named, saved, and copied to your clipboard instantly.
- **🌐 Network Pulse**: A sleek, fully custom Rofi-based Wi-Fi manager integrated directly into Waybar for instant network switching without bloated GUI apps.
- **📊 Live Telemetry**: Custom backend bash/python scripts tracking real-time CPU usage, AMD GPU metrics, VRAM, and RAM, presenting them elegantly in Waybar.
- **⌛ Screen Time Tracker**: Custom python analytics providing daily screen-time metrics natively inside your status bar.

---

## ⌨️ Essential Grimoire (Keybindings)

### Application Control
| Binding | Action | Description |
| :--- | :--- | :--- |
| `Super + Enter` | **Terminal** | Launch GPU-Accelerated Kitty |
| `Super + D` | **Launcher** | Launch Rofi App Menu |
| `Super + E` | **Files** | Launch Thunar File Manager |
| `Super + S` | **Screenshot** | Trigger Named Region Screenshot |

### System & Desktop
| Binding | Action | Description |
| :--- | :--- | :--- |
| `Super + W` | **Waybar** | Restart/Toggle Waybar |
| `Super + R` | **Reload** | Hot-reload Hyprland Configuration |
| `Super + N` | **Night Mode** | Toggle Blue Light Filter |
| `Super + Shift + L` | **Lock** | Secure System Lock (`hyprlock`) |

### Window Management
| Binding | Action | Description |
| :--- | :--- | :--- |
| `Super + Q` | **Close** | Terminate Active Window |
| `Super + F` | **Float** | Toggle Floating State |
| `Super + Space` | **Fullscreen**| Toggle Fullscreen |
| `Super + H/J/K/L` | **Focus/Snap**| Move Focus or Snap Floating Windows to Quadrants |
| `Super + LMB` | **Move** | Click & Drag to Move Window |
| `Super + RMB` | **Resize** | Click & Drag to Resize Window |
| `Super + [1-9]` | **Workspace** | Jump to Workspace 1-9 |
| `Super + Shift + [1-9]` | **Move To** | Move Window to Workspace 1-9 |

### Media & Hardware
| Binding | Action |
| :--- | :--- |
| `Media Volume Up/Down` | Increase/Decrease Volume by 5% |
| `Media Mute` | Toggle Audio Mute |
| `Brightness Up/Down` | Adjust Screen Brightness by 5% |

---

## 🛠️ Quick Start

### 1. Prerequisites
Ensure you are on a fresh or updated Arch Linux installation.

```bash
sudo pacman -Syu --noconfirm base-devel git
```

### 2. Deployment
Clone the repository and run the automated installer. The script is highly robust—it automatically installs all required dependencies (both official and AUR), backs up your current dotfiles to a timestamped archive, and cleanly symlinks the new configuration files.

```bash
git clone https://github.com/amitpadhan525/linux-dotfiles.git
cd linux-dotfiles
chmod +x install.sh
./install.sh
```

### 3. Post-Installation
1. **Monitor Setup**: Check `~/.config/hypr/conf/monitors.lua` to align with your specific displays.
2. **Review Resources**: Deep dive into the stack dependencies by checking out [`RESOURCES.md`](./RESOURCES.md).

---

## 📂 Architecture Overview (Lua-based)

```text
.
├── hyprland/
│   ├── hypr/                 # Core Hyprland logic (Lua API)
│   │   ├── conf/             # Modular split lua configs (monitors, binds, rules)
│   │   └── scripts/          # Workflow automation (snapping, screenshots)
│   ├── waybar/               # Aesthetic status engine (Catppuccin themed)
│   │   ├── scripts/          # Telemetry, Power menu, and Wifi modules
│   ├── rofi/                 # Application menus & prompt UIs
│   └── kitty/                # Terminal emulator configs
├── RESOURCES.md              # Extensive dependency deep-dive
└── install.sh                # Automated deployment orchestration
```

---

## 💻 Config Example (Lua)

Hyprland now utilizes a modular **Lua-based** configuration system for better programmatic control. Here is a highlighted example from `~/.config/hypr/conf/windowrules.lua`:

```lua
-- ─────────────────────────────────────────────────────────────────────────────
-- WINDOW RULES: FORCE TILING (Workspaces 1-6)
-- ─────────────────────────────────────────────────────────────────────────────

for i = 1, 6 do
    hl.window_rule({ match = { workspace = tostring(i) }, tile = true })
end

-- Force Tile by Class
local forced_tiling_apps = { "code", "thunar", "dolphin" }

for _, app in ipairs(forced_tiling_apps) do
    hl.window_rule({ match = { class = app }, tile = true })
end
```

---

## 📜 License

This project is licensed under the **MIT License** - see the [`LICENSE`](./LICENSE) file for details.

Copyright (c) 2026 Amit

---

<div align="center">
  <p>Made with ❤️ by <a href="https://github.com/amitpadhan525">Amit Padhan</a></p>
</div>
