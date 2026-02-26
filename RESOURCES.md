# 📦 System Resources & Dependencies

This document provides a comprehensive list of all packages, fonts, and utilities required to replicate this Hyprland configuration, updated to match the current dotfiles structure.

## 🖥️ Core Desktop Environment

| Component | Package | Description |
|-----------|---------|-------------|
| **Compositor** | `hyprland` | The dynamic tiling Wayland compositor. |
| **Status Bar** | `waybar` | Highly customizable bar for Hyprland. |
| **Launcher** | `rofi` | Application launcher and window switcher (Wayland fork). |
| **Terminal** | `alacritty` | GPU-accelerated terminal emulator (default config). |
| **Notifications** | `mako` | Lightweight notification daemon for Wayland. (Alternative: swaync/dunst) |
| **Wallpaper** | `hyprpaper` | Fast wallpaper utility. |
| **Lock Screen** | `swaylock` | Screen locking utility used in `power_menu.sh`. |

## 🛠️ Essential Utilities

| Category | Package | Description |
|----------|---------|-------------|
| **Screenshot** | `grim` | Grab images from Wayland compositor. |
| **Screenshot** | `slurp` | Select region for screenshots. |
| **Clipboard** | `wl-clipboard` | CLI copy/paste tools (`wl-copy`, `wl-paste`). |
| **Brightness** | `brightnessctl` | Hardware brightness control. |
| **Audio** | `pamixer` | PulseAudio command-line mixer to handle volume. |
| **Audio** | `pavucontrol` | GUI volume control manager. |
| **Network Manager** | `networkmanager` | Core network management daemon and `nmcli`. |
| **Network GUI** | `nm-connection-editor` | Connection editor for Waybar Wi-Fi module integrations. |
| **Bluetooth** | `blueman` | GTK+ Bluetooth Manager. |
| **Battery info** | `acpi` | Provides battery information for scripts. |

## 🎨 Fonts & Appearance

These fonts are **critical** for icons in the status bar and launcher to render correctly.

- **`ttf-jetbrains-mono-nerd`**: Primary monospaced font with icons.
- **`ttf-font-awesome`**: Icon font for specific glyphs.
- **`noto-fonts`**: Standard font family for broad language support.
- **`noto-fonts-emoji`**: Color emoji support.
- **`hyprshade`**: (AUR) Screen shader, used for the **Night Mode** script.

## 🐍 Script Dependencies

These tools are used internally by various scripts in `hypr/scripts/` and `waybar/scripts/`.

- **`jq`**: Lightweight command-line JSON processor.
- **`bc`**: Arbitrary precision calculator language.
- **`socat`**: Multipurpose relay (socket piping).
- **`python`**: Required for `screen_time.py`.
- **`playerctl`**: Utility to control media players (Spotify, VLC, Firefox, etc.).
- **`libnotify`**: Provides `notify-send` used in scripts like battery notifications and Wi-Fi menu.

## 📦 One-Liner Installation

You can install all official packages with this command:

```bash
sudo pacman -S hyprland waybar rofi alacritty mako \
    swaylock pipewire wireplumber pamixer pavucontrol \
    brightnessctl networkmanager nm-connection-editor blueman acpi \
    slurp grim wl-clipboard \
    jq bc socat playerctl python libnotify \
    ttf-jetbrains-mono-nerd noto-fonts noto-fonts-emoji
```

And AUR packages with your helper (e.g., `yay`):

```bash
yay -S hyprpaper hyprshade ttf-font-awesome
```
