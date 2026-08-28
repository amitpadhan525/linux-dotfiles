# 📦 Astraeus Resource Blueprint & Dependency Index

This document outlines the complete software stack, background services, typographical layers, and utilities that power the **Astraeus** environment. Understanding these components is critical to maintaining high performance, visual stability, and system security.

---

## 🏗️ Core Desktop Layer

These are the fundamental building blocks of the desktop environment, responsible for rendering windows, status indications, terminals, and notifications.

| Component | Official Pacman Package | System Role in Astraeus |
| :--- | :--- | :--- |
| **Compositor** | `hyprland` | The core display engine—Wayland tiling window manager (v0.55.0+). |
| **Status Bar** | `waybar` | The aesthetic status bar displaying workspaces, active modules, and dynamic media islands. |
| **App Menu** | `rofi-wayland` | Wayland-native keyboard-driven selection portal for menus, WiFi lists, and prompts. |
| **Terminal** | `kitty` | Ultra-fast, GPU-accelerated terminal emulator displaying developer outputs. |
| **File Manager** | `hyprfm` / `thunar` | Fast modern file explorer (HyprFM tabbed/miller view) & Thunar fallback. |
| **Notification (Active)**| `dunst` | Advanced notification daemon styled cohesive with the theme. |
| **Notification (Alt)** | `mako` | Lightweight notification daemon designed explicitly for Wayland. |
| **Desktop Dock** | `nwg-dock-hyprland` (AUR)| Custom CSS styled floating launcher dock. |
| **GTK Customizer** | `nwg-look` | Custom visual setting and GTK theme configuration exporter. |
| **Wallpaper** | `hyprpaper` | Hardware-accelerated wallpaper render daemon. |
| **Night Shift** | `hyprsunset` | System-level blue light filter supporting physical display voltage scaling. |

---

## 🛠️ Utility & System Layer

These utilities, background processes, and bridges give Astraeus its specialized capabilities—such as hardware scaling, region-based screenshots, sound control, and wireless orchestration.

### 📸 Graphic & Capture Engine
*   **`grim`**: Wayland screenshot utility which captures raw window buffers.
*   **`slurp`**: Dynamic coordinate area selector. It lets you select an active rectangle on your screen and outputs the coordinates directly to `grim` or `wf-recorder`.
*   **`wl-clipboard`**: Standardizes clipboard manipulation across XWayland and native Wayland clients.

### 🔌 Hardware & System Management
*   **`brightnessctl`**: Directly adjusts display backlights by editing kernel voltage levels under `/sys/class/backlight/` safely without requiring root elevation.
*   **`networkmanager` & `nm-connection-editor`**: Underlying networking framework responsible for parsing local frequencies.
*   **`blueman`**: GTK-based manager providing system-level Bluetooth pairing, discovery, and file transfer APIs.
*   **`acpi` & `upower`**: Interfaces that read raw battery metrics, current status, charge cycles, and thermal profiles.

### 🔐 Privilege & Security Management
*   **`polkit-kde-agent`**: graphical privilege authentication portal. When an application requests root-level capabilities, this agent draws a secure prompt.
*   **`gnome-keyring`**: Safe, persistent background storage for security tokens, passwords, and WiFi keys.
*   **`xsettingsd`**: Bridges classic X11 settings (such as cursor theme, font anti-aliasing, and system scaling) directly to modern Wayland clients.

---

## 🔊 Audio Architecture

Astraeus implements modern Wayland audio pipelines utilizing Pipewire for modern performance and lower latency compared to legacy PulseAudio engines.

| Component | Pacman Package | Description |
| :--- | :--- | :--- |
| **Audio Server** | `pipewire` | Multimedia server managing physical hardware paths and low-latency digital signals. |
| **Session Control**| `wireplumber` | Intelligent session manager handling policy routing and automatic device switching. |
| **CLI Mixer** | `pamixer` | PulseAudio command-line volume controller used within custom keyboard bindings. |
| **Media Controller**| `playerctl` | Command-line MPRIS media player controller used within playback keybindings. |
| **GUI Control** | `pavucontrol` | Full graphical pulse control interface for complex audio management. |
| **Integration** | `libpulse` | Compatibility library to ensure standard applications interface with Pipewire channels. |

---

## 🧠 Automation & Scripting Glue

Astraeus integrates custom scripts to link components dynamically. To run these tools, the following core programming runtimes are required:

*   **`lua`**: The primary programming interface for Hyprland v0.55+. It parses rules, environment blocks, and bindings programmatically, eliminating standard static configurations.
*   **`python`**: Powers system telemetry daemons, dynamic island timers, and screen-time tracking metrics natively inside Waybar.
*   **`jq`**: High-performance, lightweight command-line JSON processor. It formats the system outputs of Wayland and Hyprland IPC channels into parsed parameters.

Additionally, the following root-level utility scripts are provided:
*   [copy.sh](copy.sh): Collects/syncs all active local system configurations into your repository.
*   [push.sh](push.sh): Commits and pushes modifications to the GitHub remote repository.
*   [update.sh](update.sh): Pulls the latest configurations from GitHub, redeploys links, and restarts service environments. It now anchors itself to the repository root automatically.

---

## 🎨 Typographical & Visual Design

Astraeus uses specific typography selections to ensure layout alignments, icon mappings, and readable terminals function without fallback artifacts.

*   **`ttf-jetbrains-mono-nerd`**: The primary monospaced system font. Used across Kitty, Waybar telemetry readouts, and standard console inputs. Includes thousands of developer icons.
*   **`ttf-font-awesome`**: Provides graphical vector icon glyphs for core status bar modules.
*   **`noto-fonts` & `noto-fonts-emoji`**: Crucial system-wide fallback fonts for general international characters and modern high-definition emoji symbols.
*   **`ttf-outfit`** (AUR) / **`Outfit`**: A geometric font family utilized within custom user widgets, notifications, and the lockscreen typography layouts.
*   **`ttf-inter`** (AUR) / **`Inter`**: Premium font optimized for high legibility on computer screens.

---

## 📥 Comprehensive Manual Provisioning

If you prefer to install every component manually rather than executing the automated `install.sh` script, run the following commands sequentially.

### 1. Update Core Databases
Before compiling or downloading new configurations, ensure your local pacman indices are fresh:

```bash
sudo pacman -Syu
```

### 2. Install Primary Official Packages
Before compiling or downloading AUR configurations, install all standard official dependencies:

```bash
sudo pacman -S --needed --noconfirm \
    hyprland \
    hyprpaper \
    hyprlock \
    hyprsunset \
    waybar \
    rofi-wayland \
    kitty \
    thunar \
    mako \
    dunst \
    nwg-look \
    pipewire \
    pipewire-pulse \
    wireplumber \
    pamixer \
    playerctl \
    pavucontrol \
    libpulse \
    brightnessctl \
    networkmanager \
    nm-connection-editor \
    network-manager-applet \
    blueman \
    acpi \
    upower \
    slurp \
    grim \
    wf-recorder \
    wl-clipboard \
    jq \
    python \
    libnotify \
    hyprpolkitagent \
    gnome-keyring \
    xsettingsd \
    xdg-desktop-portal-hyprland \
    xdg-desktop-portal-gtk \
    ttf-jetbrains-mono-nerd \
    noto-fonts \
    noto-fonts-emoji \
    ttf-font-awesome \
    base-devel \
    git
```

### 3. Install AUR Packages
Install the custom floating dock and required system fonts using your preferred AUR helper (e.g. `yay`):

```bash
yay -S --needed --noconfirm nwg-dock-hyprland ttf-inter ttf-outfit
```

### 4. Deploy Custom Shell & Python Permissions
Ensure execution flags are configured correctly across the script ecosystem to permit proper scheduling:

```bash
# Apply executable permissions to Hyprland automation shell scripts
chmod +x ~/.config/hypr/scripts/*.sh

# Apply executable permissions to Waybar script engines
chmod +x ~/.config/waybar/scripts/*.sh
chmod +x ~/.config/waybar/scripts/*.py
```

### 5. Apply Configurations
To load the newly deployed configs without rebooting:
*   **Hyprland**: Press `Super + R` to recompile the active Lua configurations.
*   **Waybar**: Run `pkill waybar && waybar &` in your terminal to restart the status panel.
*   **Hyprpaper**: Pre-load wallpapers by calling `hyprpaper &`.

---

<div align="center">
  <p>For support and community setups, visit the main <a href="./README.md">Astraeus Core Manual</a>.</p>
</div>
