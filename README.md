# Linux Dotfiles 🐧

My personal configuration files for Arch Linux, featuring a **Hyprland**-based environment. These dotfiles are managed using Git and include setups for my window manager, status bar, application launcher, and various system scripts.

## 🚀 Features

- **Window Manager**: [Hyprland](https://github.com/hyprwm/Hyprland) - A dynamic tiling Wayland compositor with modular configuration.
- **Status Bar**: [Waybar](https://github.com/Alexays/Waybar) - Highly customizable bar with custom scripts for system monitoring (CPU/Mem, Battery, Network, etc.).
- **Application Launcher**: [Rofi](https://github.com/davatorium/rofi) - A window switcher, application launcher and dmenu replacement.
- **Scripts**: A collection of custom scripts for screenshots, power management, night mode, and more.
- **Styling**: Consistent theming across components (e.g., Catppuccin or modern dark themes).

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
└── RESOURCES.txt             # Detailed list of dependencies
└── README.md                 # This file
```

## 🛠️ Step-by-Step Installation Guide

Follow these steps to set up this environment on a fresh Arch Linux installation.

### 1. Update System & Install Base Dependencies

Ensure your system is up-to-date and has the critical tools.

```bash
sudo pacman -Syu
sudo pacman -S base-devel git
```

### 2. Install an AUR Helper

You'll likely need packages from the Arch User Repository (AUR). We recommend `yay`.

```bash
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd ..
rm -rf yay
```

### 3. Install Hyprland & Core Components

Install the window manager, status bar, launcher, and terminal.

```bash
# Core components
sudo pacman -S hyprland waybar rofi alacritty

# Install fonts (Critical for icons)
sudo pacman -S ttf-jetbrains-mono-nerd noto-fonts noto-fonts-emoji
yay -S ttf-font-awesome
```

### 4. Install Additional Tools & Utilities

These packages are required for various scripts (audio control, screenshots, etc.) to function correctly.

```bash
# Audio & Media
sudo pacman -S pipewire wireplumber pamixer pavucontrol playerctl

# Brightness & Power
sudo pacman -S brightnessctl acpi

# Script Dependencies
sudo pacman -S jq bc slurp grim wl-clipboard networkmanager bluez bluez-utils

# Night Mode (via AUR)
yay -S hyprshade
```

For a **complete list** of every package used, check the [RESOURCES.txt](./RESOURCES.txt) file included in this repository.

### 5. Clone the Repository

Clone these dotfiles to your preferred location (e.g., `~/github/linux-dotfiles`).

```bash
mkdir -p ~/github
git clone https://github.com/amitpadhan525/linux-dotfiles.git ~/github/linux-dotfiles
```

### 6. Symlink Configurations

This step links the configuration files from the repository to your system's config directory. This way, any changes you make in `~/github/linux-dotfiles` are immediately applied, and you can easily push updates to GitHub.

**Warning**: Back up existing configs in `~/.config/` before running these commands if you have any.

```bash
# Create base config directory
mkdir -p ~/.config

# -----------------
# Hyprland Setup
# -----------------
# If ~/.config/hypr exists, rename it first: mv ~/.config/hypr ~/.config/hypr.bak
ln -s ~/github/linux-dotfiles/hyprland/hypr ~/.config/hypr

# -----------------
# Waybar Setup
# -----------------
# If ~/.config/waybar exists, rename it: mv ~/.config/waybar ~/.config/waybar.bak
ln -s ~/github/linux-dotfiles/hyprland/waybar ~/.config/waybar

# -----------------
# Rofi Setup
# -----------------
# If ~/.config/rofi exists, rename it: mv ~/.config/rofi ~/.config/rofi.bak
ln -s ~/github/linux-dotfiles/hyprland/rofi ~/.config/rofi
```

### 7. Finalize Setup

1.  **Grant Execution Permissions**: Ensure all scripts are executable.
    ```bash
    chmod +x ~/.config/hypr/scripts/*.sh
    chmod +x ~/.config/waybar/scripts/*.sh
    chmod +x ~/.config/hypr/autostart.sh
    ```

2.  **Monitor Configuration**:
    Edit `~/.config/hypr/monitors.conf` to match your screen resolution and refresh rate.
    Run `hyprctl monitors` to see your connected displays.

3.  **Laptop Specifics** (Optional):
    If you are on a laptop, ensure `acpi` is installed for battery stats and `brightnessctl` for screen brightness keys.

4.  **Reboot**:
    Restart your computer and select **Hyprland** from your login manager (e.g., sddm, gdm, or tty).

## ⌨️ Keybindings (Quick Start)

Here are a few default bindings (check `~/.config/hypr/keybinds.conf` for the full list):

- `Super + Q`: Open Terminal (Alacritty)
- `Super + R`: Open Application Launcher (Rofi)
- `Super + C`: Close active window
- `Super + M`: Exit Hyprland
- `Super + E`: Open File Manager
- `Super + V`: Toggle Floating window
- `Super + P`: Pseudo Dwindle

## 🔧 Troubleshooting

- **Waybar missing icons**: Ensure you installed `ttf-jetbrains-mono-nerd` and `ttf-font-awesome`.
- **Audio keys not working**: Make sure `pamixer` is installed (`sudo pacman -S pamixer`).
- **Screenshots fail**: Ensure `slurp` and `grim` are installed.
- **Gray screen / no wallpaper**: Install `hyprpaper` and configure a wallpaper in `~/.config/hypr/hyprpaper.conf` or add it to `autostart.sh`.

## ⚠️ Disclaimer

These configurations are tailored to my specific hardware. Please review `monitors.conf` and `autostart.sh` before applying them to avoid issues with different display setups.
