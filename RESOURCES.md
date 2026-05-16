# 📦 Resource Blueprint

This document outlines the software stack and dependencies that power the **Astraeus** environment. Understanding these components is key to maintaining a stable and efficient system.

---

## 🏗️ Core Stack
The fundamental building blocks of the desktop experience.

| Component | Package | Role |
| :--- | :--- | :--- |
| **Compositor** | `hyprland` | The heart of the system—Wayland tiling compositor. |
| **Status Bar** | `waybar` | Highly customized system monitor and dashboard. |
| **App Launcher** | `rofi-wayland` | The graphical interface for apps and custom menus. |
| **Terminal** | `kitty` | Fast, GPU-based terminal emulator. |
| **File Manager** | `thunar` | Lightweight GTK file explorer. |
| **Notification** | `mako` | Lightweight Wayland notification daemon. |

---

## 🛠️ Utility Layer
Scripts and small binaries that enable "Superpowers" like screenshots and brightness control.

### 📸 Imaging & Media
- **`grim` & `slurp`**: Screen capture and region selection.
- **`wl-clipboard`**: System-wide clipboard management for Wayland.
- **`pamixer`**: Audio volume control.

### 🔌 System Management
- **`brightnessctl`**: Backlight control for laptop displays.
- **`networkmanager`**: Backend for Wi-Fi and Ethernet connectivity.
- **`blueman`**: Bluetooth device management.
- **`acpi` & `upower`**: Hardware state monitoring (Battery/Thermal).

### 🔐 Security & Integration
- **`gnome-keyring`**: Secure storage for passwords and keys.
- **`polkit-kde-agent`**: Privilege elevation GUI.
- **`xsettingsd`**: Bridges X11 settings to Wayland applications.

---

## 🧠 Scripting Glue
Tools used within our internal logic to parse data and automate tasks.

- **`lua`**: The core language for configuring and orchestrating Hyprland settings, window rules, and startup logic in v0.55+.
- **`jq`**: Lightweight JSON processor (critical for Waybar and Hyprland IPC).
- **`python`**: Powers complex logic like uptime tracking and telemetry.

### Example Lua IPC Hook
If you want to interact programmatically with Hyprland inside your configs:
```lua
-- Execute a system command via Hyprland Lua API
hl.execute("waybar &")
```

---

## 🎨 Visual Assets
Required for the UI to render correctly without missing icons or weird spacing.

- **`ttf-jetbrains-mono-nerd`**: The primary UI and terminal font.
- **`ttf-font-awesome`**: Icon glyphs for Waybar modules.
- **`noto-fonts-emoji`**: Full emoji support across the system.

---

## 📥 Manual Provisioning
If you wish to install everything manually without the `install.sh` script:

```bash
# Core & Utilities
sudo pacman -S hyprland waybar rofi-wayland kitty thunar mako \
    hyprlock pipewire wireplumber pamixer pavucontrol \
    brightnessctl networkmanager nm-connection-editor blueman acpi \
    upower slurp grim wl-clipboard jq python libnotify \
    xsettingsd polkit-kde-agent gnome-keyring libpulse \
    ttf-jetbrains-mono-nerd noto-fonts noto-fonts-emoji base-devel git

# AUR Specifics
yay -S hyprpaper hyprsunset ttf-font-awesome
```
