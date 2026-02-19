# Linux Dotfiles 🐧

My personal configuration files for Arch Linux, featuring a **Hyprland**-based environment. These dotfiles are managed using Git and include setups for my window manager, status bar, application launcher, and various system scripts.

## 🚀 Features

- **Window Manager**: [Hyprland](https://github.com/hyprwm/Hyprland) - A dynamic tiling Wayland compositor with modular configuration.
- **Status Bar**: [Waybar](https://github.com/Alexays/Waybar) - Highly customizable bar with custom scripts for system monitoring (CPU/Mem, Battery, Network, etc.).
- **Application Launcher**: [Rofi](https://github.com/davatorium/rofi) - A window switcher, application launcher and dmenu replacement.
- **Scripts**: A collection of custom scripts for screenshots, power management, night mode, and more.
- **Styling**: Consistent theming across components.

## 📂 Directory Structure

Here's an overview of the repository layout:

```
linux-dotfiles/
├── hyprland/
│   ├── hypr/                 # Hyprland core configurations
│   │   ├── hyprland.conf     # Main entry point
│   │   ├── keybinds.conf     # Keybinding definitions
│   │   ├── monitors.conf     # Display output settings
│   │   ├── rules.conf        # Window rules
│   │   ├── env.conf          # Environment variables
│   │   ├── theme.conf        # Visual theme settings
│   │   ├── scripts/          # Helper scripts (screenshot, floating toggle, etc.)
│   │   └── ...
│   ├── waybar/               # Status bar configuration
│   │   ├── config            # Main Waybar configuration
│   │   ├── style.css         # Visual styling
│   │   ├── scripts/          # Custom modules (battery, network, power menu, etc.)
│   │   └── ...
│   └── rofi/                 # Rofi configuration
│       ├── simple.rasi       # Rofi theme
│       └── simple-modern.rasi # Modern Rofi theme variant
├── push.sh                   # Quick git push script
└── README.md                 # This file
```

## 🛠️ Configurations in Detail

### Hyprland (`hyprland/hypr`)
The Hyprland configuration is split into multiple files for better organization:
- `hyprland.conf`: The main configuration file that sources others.
- `keybinds.conf`: comprehensive keybindings for window management and application launching.
- `monitors.conf`: Setup for your specific monitor layout.
- `rules.conf`: Window rules for floating windows, opacity, etc.
- `theme.conf`: Appearance settings like borders, gaps, and colors.
- `autostart.sh`: Script to launch background applications on login.

### Waybar (`hyprland/waybar`)
Includes a fully featured bar with custom scripts:
- **Battery**: Notifications for low battery and charging status (`battery_notify.sh`).
- **Network**: Info and menu (`network_info.sh`, `wifi_menu.sh`).
- **Power Menu**: Custom power management menu (`power_menu.sh`).
- **Night Mode**: Toggle for blue light filter (`night_mode.sh`).
- **System Stats**: CPU, Memory, Disk usage monitoring.

### Rofi (`hyprland/rofi`)
Configurations for the application launcher and menus:
- Includes modern themes (`simple.rasi`, `simple-modern.rasi`) to match the overall aesthetic.

## 📦 Requirements

To use these configurations effectively, you will need an Arch Linux system (or similar) with the following packages installed:

- **Core**: `hyprland`, `waybar`, `rofi`, `alacritty` (or your preferred terminal)
- **Shell**: `bash`, `zsh`
- **Fonts**: Nerd Fonts (e.g., `ttf-jetbrains-mono-nerd`, `ttf-font-awesome`) for icons.
- **Utilities**: 
  - `git`
  - `hyprpaper` (wallpapers)
  - `mako` or `dunst` (notifications)
  - `pipewire`, `wireplumber` (audio)
  - `python` (for some scripts)
  - `jq` (often used in scripts)
  - `brightnessctl` (brightness control)
  - `playerctl` (media control)

## 🔧 Installation

1.  **Clone the repository**:
    ```bash
    git clone https://github.com/amitpadhan525/linux-dotfiles.git ~/github/linux-dotfiles
    ```

2.  **Symlink configurations**:
    Backup your existing configurations first, then link these folders to `~/.config/`.

    ```bash
    # Create the config directory if it doesn't exist
    mkdir -p ~/.config

    # Symlink Hyprland
    ln -s ~/github/linux-dotfiles/hyprland/hypr ~/.config/hypr

    # Symlink Waybar
    ln -s ~/github/linux-dotfiles/hyprland/waybar ~/.config/waybar

    # Symlink Rofi
    ln -s ~/github/linux-dotfiles/hyprland/rofi ~/.config/rofi
    ```

3.  **Restart**:
    - **Hyprland**: Use your exit bind to log out and log back in, or reload if applicable.
    - **Waybar**: Typically reloads automatically or can be restarted with `pkill waybar && waybar`.

## ⚠️ Disclaimer

These configurations are tailored to my specific hardware and preferences. Please review the files (especially `monitors.conf` and `autostart.sh`) before applying them to your system to ensure they match your environment.
