# Linux Dotfiles 🐧

My personal configuration files for Arch Linux, featuring a Hyprland-based environment. These dotfiles are managed using Git and include setups for my window manager, status bar, and various system scripts.

## 🚀 Features

- **Window Manager**: [Hyprland](https://github.com/hyprwm/Hyprland) - A dynamic tiling Wayland compositor.
- **Status Bar**: [Waybar](https://github.com/Alexays/Waybar) - Highly customizable Wayland bar for Hyprland.
- **Shell**: Bash / Zsh configuration.
- **Terminal Utilities**: Custom scripts for system management and automation.
- **Autostart**: Configurations for launching essential applications on startup.

## 📂 Directory Structure

Here's an overview of the repository layout:

```
linux-dotfiles/
├── hyprland/
│   ├── hypr/           # Hyprland core configurations
│   │   ├── hyprland.conf   # Main compositor config
│   │   ├── autostart.sh    # Startup script
│   │   ├── keybinds.conf   # Keybinding definitions
│   │   ├── monitors.conf   # Display output settings
│   │   ├── rules.conf      # Window rules
│   │   └── ...
│   └── waybar/         # Status bar configuration
│       ├── config          # Waybar modules layout
│       └── style.css       # Visual styling
├── push.sh             # Quick git push script
└── README.md           # This file
```

## 🛠️ Requirements

To use these configurations effectively, you will need an Arch Linux system (or similar) with the following packages installed:

- **Hyprland**: `hyprland`
- **Waybar**: `waybar`
- **Shell**: `bash` or `zsh`
- **Fonts**: Consider installing patched fonts (e.g., Nerd Fonts) for icons in Waybar.
- **Utilities**: `git`, `hyprpaper` (for wallpapers), `mako` (notifications), `pipewire` (audio), etc.

## 📦 Usage & Installation

1.  **Clone the repository**:
    ```bash
    git clone https://github.com/amitpadhan525/linux-dotfiles.git ~/github/linux-dotfiles
    ```

2.  **Symlink configurations**:
    It is recommended to symlink the folders to your `~/.config/` directory to keep them updated with the repository.

    ```bash
    # Example for Hyprland
    ln -s ~/github/linux-dotfiles/hyprland/hypr ~/.config/hypr

    # Example for Waybar
    ln -s ~/github/linux-dotfiles/hyprland/waybar ~/.config/waybar
    ```

    *Alternatively, you can copy the files directly if you prefer not to use symlinks.*

3.  **Restart Hyprland**:
    Use `Super + M` (or your configured bind) to exit or reload Hyprland for changes to take effect.

## ⚠️ Disclaimer

These configurations are tailored to my specific hardware and preferences. Please review the files (especially `monitors.conf` and `autostart.sh`) before applying them to your system to ensure they match your environment.

