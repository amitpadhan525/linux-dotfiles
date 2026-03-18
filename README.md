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

- **Window Manager**: `Hyprland` - Buttery smooth Wayland compositor with modular configuration files.
- **Status Bar**: `Waybar` - Highly customized with modules for CPU, Memory, Disk, Network, Battery, and more.
- **Application Launcher**: `Rofi` (Wayland fork) - Themed with `simple.rasi` and `simple-modern.rasi` for a beautiful, distraction-free app searching, menus, and more.
- **Terminal Emulator**: `Kitty` (previously Alacritty) - GPU-accelerated terminal for ultimate performance.

---

## 🥷 Hidden Features & Custom Superpowers

This configuration goes beyond basic window management. It includes several custom-built tools injected neatly into the workflow:

### 📸 Smart Named Screenshots (`Super + S`)
Instead of just saving a generic timestamped file, hitting `Super + S` triggers `slurp` for region selection, takes the shot with `grim`, and instantly pops open a **Rofi prompt** asking you to name the file! Leave it blank for a timestamp fallback. It also auto-copies the file path to `wl-clipboard` and sends a desktop notification.

### 🌐 Rofi Wi-Fi Manager
Clicking the network module in Waybar launches `wifi_menu.sh`, a fully self-contained GUI built with Rofi. It lists available SSIDs, lets you enable/disable Wi-Fi, prompts for WPA/WEP passwords securely using a custom Rofi password field, and connects seamlessly via `nmcli`.

### ⚡ Elegant Power Menu
A heavily styled Rofi menu (`power_menu.sh`) handles your system's power states: Lock (`swaylock`), Logout, Suspend, Hibernate, Reboot, and Shutdown.

### 🌙 Smart Night Mode (`Super + N`)
Quickly toggle a blue-light filter to save your eyes at night. It uses `hyprsunset` (or `gammastep` fallback) and writes its state to a hidden file so Waybar's icon (`` / ``) always accurately reflects the active state.

### 🪟 Mass Floating Toggle (`Super + F`)
Tired of moving windows one by one? The `toggle_floating.sh` script detects all active clients in your workspace and toggles **all of them** simultaneously between floating and tiling mode, complete with system notifications!

### ⏱️ Python Screen Time Tracker
Ever wondered how much time you've spent on your machine today? A custom python script (`screen_time.py`) parses system login records via `last -R`, accurately ignores overlapped terminal sessions (`pts/X`), and calculates your exact screen time for the day, beautifully displayed on Waybar.

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
| `Super + R` | Reload Hyprland | `hyprctl reload` |

### Window Operations
| Shortcut | Action |
|----------|--------|
| `Super + Q` | Close Active Window |
| `Super + F` | Toggle Floating Mode (Mass Toggle) |
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
| `XF86MonBrightnessUp/Down` | Screen Brightness +/- 10% (`brightnessctl`) |
| `XF86AudioRaise/LowerVolume`| Volume Control +/- 5% (`pamixer`) |
| `XF86AudioMute` | Toggle Audio Mute (`pamixer -t`) |

---

## 🚀 Installation & Setup

Want this setup on your Arch Linux machine? Follow these simple steps.

### 1. Base System Requirements
First, make sure your system is up to date and has essential tools:
```bash
sudo pacman -Syu
sudo pacman -S base-devel git thunar kitty
```

### 2. Install AUR Helper (`yay`)
If you don't already have `yay`:
```bash
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd ..
rm -rf yay
```

### 3. Install All Dependencies
*(See [RESOURCES.md](./RESOURCES.md) for a detailed breakdown of what each package does).*
```bash
# Core Environment
sudo pacman -S hyprland waybar rofi mako swaylock pipewire wireplumber pamixer pavucontrol brightnessctl networkmanager nm-connection-editor blueman acpi slurp grim wl-clipboard jq bc socat playerctl python libnotify

# Fonts (Crucial for UI Icons)
sudo pacman -S ttf-jetbrains-mono-nerd noto-fonts noto-fonts-emoji
yay -S ttf-font-awesome

# AUR Utilities
yay -S hyprpaper hyprsunset
```

### 4. Clone & Link Configurations
Clone the dotfiles into your `~/github` folder and use the provided scripts/symlinks to apply them.

```bash
mkdir -p ~/github ~/.config
git clone https://github.com/amitpadhan525/linux-dotfiles.git ~/github/linux-dotfiles

# Backup existing configs to avoid data loss
mv ~/.config/hypr ~/.config/hypr.bak 2>/dev/null
mv ~/.config/waybar ~/.config/waybar.bak 2>/dev/null
mv ~/.config/rofi ~/.config/rofi.bak 2>/dev/null

# Symlink to the repository
ln -s ~/github/linux-dotfiles/hyprland/hypr ~/.config/hypr
ln -s ~/github/linux-dotfiles/hyprland/waybar ~/.config/waybar
ln -s ~/github/linux-dotfiles/hyprland/rofi ~/.config/rofi
```

### 5. Finalizing Operations
Grant execution permissions to all utility scripts, otherwise buttons/shortcuts will silently fail!
```bash
chmod +x ~/.config/hypr/scripts/*.sh
chmod +x ~/.config/hypr/autostart.sh
chmod +x ~/.config/waybar/scripts/*.sh
chmod +x ~/.config/waybar/scripts/*.py
```

Before restarting, explicitly check `~/.config/hypr/conf/monitors.conf` to align with your personal display setup (run `hyprctl monitors` if currently on Hyprland).

***

## 📂 Directory Structure Overview

```
linux-dotfiles/
├── hyprland/
│   ├── hypr/                 # Hyprland core brain
│   │   ├── hyprland.conf     # Standard entry point
│   │   ├── autostart.sh      # Launch environment daemons
│   │   ├── conf/             # Modular split configurations (workspaces, keybinds, etc)
│   │   └── scripts/          # Floating toggler, screenshot taker, etc.
│   ├── waybar/               # The Status Bar
│   │   ├── config            # Module layout
│   │   ├── style.css         # Visual aesthetic rules
│   │   └── scripts/          # Superpowers: wifi_menu, power_menu, screen_time
│   └── rofi/                 # Application Launcher + GUIs
│       ├── simple.rasi       # Custom aesthetic styling
│       └── simple-modern.rasi
├── RESOURCES.md              # Exhaustive map of all dependencies
├── copy.sh                   # Script to pull latest system configs into repo
├── push.sh                   # Fast GitHub commit/push utility
└── README.md                 # You are here!
```
