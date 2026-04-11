<div align="center">
  <h1>🐧 Modern Arch Linux Dotfiles</h1>
  <p><b>A highly optimized, aesthetic, and functional Hyprland environment.</b></p>

  [![Window Manager: Hyprland](https://img.shields.io/badge/Window%20Manager-Hyprland-blue?style=for-the-badge&logo=linux)](https://hyprland.org)
  [![Status Bar: Waybar](https://img.shields.io/badge/Status%20Bar-Waybar-green?style=for-the-badge&logo=linux)](https://github.com/Alexays/Waybar)
  [![Launcher: Rofi](https://img.shields.io/badge/Launcher-Rofi-purple?style=for-the-badge&logo=linux)](https://github.com/davatorium/rofi)
  [![Terminal: Kitty](https://img.shields.io/badge/Terminal-Kitty-red?style=for-the-badge&logo=linux)](https://sw.kovidgoyal.net/kitty/)
</div>

---

Welcome to my personal configuration files for Arch Linux. This setup uses **Hyprland** as a dynamic tiling Wayland compositor, tied together with carefully crafted custom scripts to elevate the raw user experience. It's built for speed, aesthetics, and maximum keyboard-driven productivity.

## ✨ Core Components

- **Window Manager**: `Hyprland` - Buttery smooth Wayland compositor with modular configuration files located in `hypr/conf/`.
- **Status Bar**: `Waybar` - Highly customized with modules for CPU, Memory, GPU, Disk, Network, Battery, and more.
- **Application Launcher**: `Rofi` (Wayland fork) - Themed with `simple.rasi` and `simple-modern.rasi`.
- **Terminal Emulator**: `Kitty` - GPU-accelerated terminal for ultimate performance.

---

## 🥷 Hidden Features & Custom Superpowers

This configuration goes beyond basic window management. It includes several custom-built tools injected neatly into the workflow:

### 📸 Smart Named Screenshots (`Super + S`)
Instead of just saving a generic timestamped file, hitting `Super + S` triggers `slurp` for region selection, takes the shot with `grim`, and instantly pops open a **Rofi prompt** asking you to name the file! Leave it blank for a timestamp fallback. It also auto-copies the file path to `wl-clipboard` and sends a desktop notification.

### 📊 Real-time System Monitoring
The Waybar configuration uses advanced custom scripts for granular monitoring:
- **CPU & Memory**: Accurate real-time usage using `/proc/stat` and `free` (via `custom_cpu.sh`, `custom_mem.sh`).
- **GPU Tracker**: Dedicated monitoring for AMD GPUs showing busy percentage, VRAM usage, and temperatures (`custom_gpu.sh`).
- **Disk Insight**: Hover over the disk icon to see a detailed breakdown of Root and Home partition usage (`disk_info.sh`).
- **RAM Top 5**: Quickly identify resource hogs; the RAM module can trigger a notification showing the top 5 memory-consuming processes.
- **Screen Time Tracker**: Monitors system uptime logically across suspend states, displayed directly in Waybar via `screen_time.py`.

### 🌐 Rofi Wi-Fi Manager
Clicking the network module in Waybar launches `wifi_menu.sh`, a GUI built with Rofi. It lists available SSIDs, lets you enable/disable Wi-Fi, prompts for passwords securely, and connects via `nmcli`.

### ⚡ Elegant Power Menu
A styled Rofi menu (`power_menu.sh`) handles Lock (`hyprlock`), Logout, Suspend, Hibernate, Reboot, and Shutdown.

### 🌙 Smart Night Mode (`Super + N`)
Quickly toggle a blue-light filter to save your eyes. It uses `hyprsunset` for a native Wayland experience, filtering the screen to a comfortable 4500K.

### 🔋 Battery Intelligence
Includes `battery_notify.sh` which monitors levels in the background and sends critical desktop notifications when the battery drops below 20% and 10%.

### 🔐 Seamless Secrets Management
The environment is built to sustain persistent logins (like Brave browser sessions) across reboots by automatically initializing `gnome-keyring-daemon` and handling privilege elevations through `polkit-kde-agent` on startup.

---

## ⌨️ Master Keybindings

A complete map to navigate the interface without ever touching your mouse.

### Applications & System
| Shortcut | Action | Command/Script Under the Hood |
|----------|--------|-------------------------------|
| `Super + Return` | Open Terminal | `kitty` |
| `Super + D` | App Launcher | `rofi -show drun` |
| `Super + E` | File Manager | `thunar` |
| `Super + W` | Toggle Status Bar | `killall waybar` & rerun |
| `Super + S` | Smart Screenshot | `named_screenshot.sh` |
| `Super + N` | Toggle Night Mode | `hyprsunset` toggle |
| `Super + L` | Lock Screen | `hyprlock` |
| `Super + R` | Reload Hyprland | `hyprctl reload` |

### Window Operations
| Shortcut | Action |
|----------|--------|
| `Super + Q` | Close Active Window |
| `Super + F` | Toggle Floating Mode |
| `Super + Space`| Toggle Fullscreen |
| `Super + H/J/K/L`| Vim-like Focus (Left, Down, Up, Right) |
| `Super + Mouse(L)`| Drag & Move Window |
| `Super + Mouse(R)`| Drag to Resize Window |

### Workspaces
| Shortcut | Action |
|----------|--------|
| `Super + [1-9]` | Switch to Workspace 1-9 |
| `Super + Shift + [1-9]` | Move Active Window to Workspace 1-9 |

### Hardware Media Keys
| Key | Action |
|-----|--------|
| `XF86MonBrightnessUp/Down` | Screen Brightness +/- 10% |
| `XF86AudioRaise/LowerVolume`| Volume Control +/- 5% (`wpctl`) |
| `XF86AudioMute` | Toggle Audio Mute (`wpctl`) |

---

## 🚀 Installation & Setup

Want this setup on your Arch Linux machine? Follow these simple steps.

### 1. Base System Requirements
First, make sure your system is up to date:
```bash
sudo pacman -Syu
sudo pacman -S base-devel git
```

### 2. Auto-Installation
We provide a comprehensive installer that handles dependencies, AUR packages, and symlinking.

```bash
git clone https://github.com/amitpadhan525/linux-dotfiles.git ~/github/linux-dotfiles
cd ~/github/linux-dotfiles
chmod +x install.sh
./install.sh
```

### 3. Finalizing Operations
Before restarting, check `~/.config/hypr/conf/monitors.conf` to align with your personal display setup. Run `hyprctl monitors` to see your current display names.

***

## 📂 Directory Structure Overview

```
linux-dotfiles/
├── hyprland/
│   ├── hypr/                 # Hyprland core brain
│   │   ├── hyprland.conf     # Standard entry point
│   │   ├── hyprlock.conf     # Lock screen configuration
│   │   ├── autostart.sh      # Launch environment daemons
│   │   ├── setup_autostart.sh # Dynamic autostart setup script
│   │   ├── conf/             # Modular split configurations
│   │   └── scripts/          # Floating toggler, screenshot taker, etc.
│   ├── kitty/                # Terminal Emulator
│   │   └── kitty.conf        # Kitty config
│   ├── waybar/               # The Status Bar
│   │   ├── config            # Module layout
│   │   ├── config-dock.jsonc # Alternative dock-style layout
│   │   ├── style.css         # Visual aesthetic rules
│   │   └── scripts/          # Waybar powerups (CPU, GPU, RAM, Disk, etc)
│   └── rofi/                 # Application Launcher + GUIs
│       ├── simple.rasi       # Custom aesthetic styling
│       └── simple-modern.rasi
├── RESOURCES.md              # Exhaustive map of all dependencies
├── install.sh                # Main automated installer
├── copy.sh                   # Script to pull latest system configs into repo
├── push.sh                   # Fast GitHub commit/push utility
└── README.md                 # You are here!
```
