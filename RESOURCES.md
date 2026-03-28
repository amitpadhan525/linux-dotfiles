# 📦 System Resources & Hidden Dependencies

This document provides absolute transparency on every tool, font, and dependency required for this dotfiles environment to function perfectly. It maps out **what** you are installing and **why** it sits inside this ecosystem.

---

## 🖥️ Core Desktop Foundation

These form the very backbone of the environment shell.

| Component | Package | Purpose in Dotfiles |
|-----------|---------|---------------------|
| **Compositor** | `hyprland` | The Wayland tiling manager that handles everything visual. |
| **Status Bar** | `waybar` | Renders our system dashboard, holding our custom Python/Bash scripts. |
| **App Launcher** | `rofi` | Triggers apps via `Super + D`, and serves as the UI engine for Wi-Fi and Power menus. |
| **Terminal** | `kitty` | High-performance, GPU-accelerated terminal. |
| **File Manager** | `thunar` | Fast GTK-based file manager triggered via `Super + E`. |
| **Notifications** | `mako` | Handles desktop notifications (used by scripts for battery, screenshots, and floating toggles). |
| **Wallpaper** | `swaybg` / `hyprpaper` | Renders background imagery flawlessly on Wayland outputs. |
| **Locking** | `hyprlock` | Secures the system. Invoked directly by the `power_menu.sh` module and upon autostart. |

---

## 🛠️ Superpower / Script Dependencies

Various utility commands that unlock the "hidden" tools in the `.config` directories. Missing these will cause keyboard shortcuts or Waybar modules to silently fail!

| Category | Package | Script / Feature Integration |
|----------|---------|------------------------------|
| **Screen Capture** | `grim` + `slurp` + `wl-clipboard` | Powers `named_screenshot.sh` (Super+S). `slurp` grabs the region, `grim` takes the image, `wl-clipboard` copies the path. |
| **Night Mode** | `hyprsunset` | Triggered by `Super + N` to filter blue light (fallback `gammastep` or `hyprshade` also supported). |
| **Audio Mgmt** | `pamixer` + `pavucontrol` | `pamixer` controls volume directly via media keys. `pavucontrol` is the GUI mixer. |
| **Audio Core** | `pipewire` + `wireplumber` | Modern audio routing layer required for Wayland compositors. |
| **Brightness** | `brightnessctl` | Managed strictly by laptop display hardware keys. |
| **Network Manager** | `networkmanager` (nmcli) | Crucial for `wifi_menu.sh`, directly parsing interfaces and connecting. |
| **Network GUI** | `nm-connection-editor` | A fallback GTK editor linked within the Rofi Wi-Fi manager. |
| **Bluetooth** | `blueman` | GTK frontend for handling Bluetooth hardware. |
| **Hardware Stats** | `acpi` | Scraped by `battery_info.sh` and `battery_notify.sh` to parse percentages and send alerts. |

---

## 🐍 String Processing & Math Tools

These dependencies act as the "glue" inside our `.sh` and `.py` files.

- **`jq`**: JSON processor—used by `toggle_floating.sh` to mass-toggle windows and by various Waybar custom scripts for JSON output formatting.
- **`python`**: Runs the custom `screen_time.py` tracker mapping out login histories.
- **`bc`**: Command line calculator, necessary for division and rounding inside custom system metric scripts.
- **`socat`**: Socket relay processor used heavily in communicating with Hyprland's IPC socket.
- **`playerctl`**: Utility used by Waybar to control media playback.
- **`libnotify`**: Provides the `notify-send` binary, allowing scripts to talk to the user via UI popups.

---

## 🎨 Fonts (Critical for UI integrity)

If these are not installed, Waybar and Rofi will display broken squares instead of icons!

- **`ttf-jetbrains-mono-nerd`**: Primary font rendering clean text alongside vast glyph options.
- **`ttf-font-awesome`**: Provides legacy icon mappings required by standard Waybar modules.
- **`noto-fonts` & `noto-fonts-emoji`**: Crucial fallbacks for colored emojis and broad unicode ranges.

---

## 🚀 The Universal Install Command

To immediately fetch the vast majority of these dependencies on an Arch system:

```bash
# Standard Repositories
sudo pacman -S hyprland waybar rofi kitty thunar mako \
    hyprlock pipewire wireplumber pamixer pavucontrol \
    brightnessctl networkmanager nm-connection-editor blueman acpi \
    slurp grim wl-clipboard \
    jq bc socat playerctl python libnotify \
    ttf-jetbrains-mono-nerd noto-fonts noto-fonts-emoji

# AUR Packages
yay -S hyprpaper hyprsunset ttf-font-awesome
```
