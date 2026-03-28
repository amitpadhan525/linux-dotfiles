#!/bin/bash

# =======================================================================
# Arch Linux Dotfiles Installer
# =======================================================================

# Configuration and variables
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"

# Official Repository Packages
OFFICIAL_PKGS=(
    "hyprland" "waybar" "rofi" "kitty" "thunar" "mako"
    "hyprlock" "pipewire" "wireplumber" "pamixer" "pavucontrol"
    "brightnessctl" "networkmanager" "nm-connection-editor" "blueman" "acpi"
    "slurp" "grim" "wl-clipboard" "jq" "bc" "socat" "playerctl" "python" "libnotify"
    "ttf-jetbrains-mono-nerd" "noto-fonts" "noto-fonts-emoji" "base-devel" "git"
)

# AUR Packages
AUR_PKGS=(
    "hyprpaper" "hyprsunset" "ttf-font-awesome"
)

# Output Colors (Premium Palette)
GREEN="\e[32m"
BLUE="\e[34m"
RED="\e[31m"
YELLOW="\e[33m"
CYAN="\e[36m"
MAGENTA="\e[35m"
RESET="\e[0m"

# Helper functions
info() { echo -e "${BLUE}[*] $1${RESET}"; }
success() { echo -e "${GREEN}[+] $1${RESET}"; }
warn() { echo -e "${YELLOW}[!] $1${RESET}"; }
error() { echo -e "${RED}[x] $1${RESET}"; }

clear
echo -e "${MAGENTA}"
echo "    __  __                     __                 __  "
echo "   / / / /_  ______  _____/ /___ _____  ____/ /  "
echo "  / /_/ / / / / __ \/ ___/ / __ \`/ __ \/ __  /   "
echo " / __  / /_/ / /_/ / /  / / /_/ / / / / /_/ /    "
echo "/_/ /_/\__, / .___/_/  /_/\__,_/_/ /_/\__,_/_    "
echo "      /____/_/                                   "
echo -e "${CYAN}             Premium Arch Linux Dotfiles Installer${RESET}"
echo "--------------------------------------------------------"

# 1. OS Check
if [ ! -f /etc/arch-release ]; then
    error "Critical Error: This script is built for Arch Linux-based systems only."
    exit 1
fi
success "Arch Linux system verified."

# 2. System Update & Base Requirements
info "Synchronizing package databases..."
sudo pacman -Syu --noconfirm
sudo pacman -S --needed --noconfirm base-devel git

# 3. Check for AUR Helper (yay)
if ! command -v yay &> /dev/null; then
    info "Installing 'yay' AUR helper..."
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay || exit
    makepkg -si --noconfirm
    cd "$DOTFILES_DIR" || exit
    rm -rf /tmp/yay
fi
success "AUR helper ready."

# 4. Install Official Packages
info "Provisioning official repository packages..."
for pkg in "${OFFICIAL_PKGS[@]}"; do
    if ! pacman -Qs "^$pkg$" &> /dev/null; then
        info "Installing $pkg..."
        sudo pacman -S --noconfirm "$pkg"
    fi
done
success "Official packages synchronized."

# 5. Install AUR Packages
info "Provisioning AUR packages..."
for pkg in "${AUR_PKGS[@]}"; do
    if ! pacman -Qs "^$pkg$" &> /dev/null; then
        info "Installing $pkg (AUR)..."
        yay -S --noconfirm "$pkg"
    fi
done
success "AUR packages synchronized."

# 6. Backup Existing Configurations
info "Creating system backups..."
BACKUP_PATH="$CONFIG_DIR/config-backups_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_PATH"

backup_config() {
    local target="$1"
    if [ -d "$CONFIG_DIR/$target" ] && [ ! -L "$CONFIG_DIR/$target" ]; then
        mv "$CONFIG_DIR/$target" "$BACKUP_PATH/"
        success "Backed up ~/.config/$target"
    elif [ -L "$CONFIG_DIR/$target" ]; then
        rm "$CONFIG_DIR/$target"
    fi
}

for cfg in "hypr" "waybar" "rofi" "kitty"; do
    backup_config "$cfg"
done

# 7. Symlink Configurations
info "Linking configuration modules..."
ln -sf "$DOTFILES_DIR/hyprland/hypr" "$CONFIG_DIR/hypr"
ln -sf "$DOTFILES_DIR/hyprland/waybar" "$CONFIG_DIR/waybar"
ln -sf "$DOTFILES_DIR/hyprland/rofi" "$CONFIG_DIR/rofi"
ln -sf "$DOTFILES_DIR/hyprland/kitty" "$CONFIG_DIR/kitty"
success "Configuration landscape established."

# 8. Set Execute Permissions
info "Securing script execution permissions..."
find "$CONFIG_DIR/hypr/scripts" -type f -name "*.sh" -exec chmod +x {} + 2>/dev/null
chmod +x "$CONFIG_DIR/hypr/autostart.sh" 2>/dev/null
chmod +x "$CONFIG_DIR/hypr/setup_autostart.sh" 2>/dev/null
find "$CONFIG_DIR/waybar/scripts" -type f -name "*.sh" -exec chmod +x {} + 2>/dev/null
find "$CONFIG_DIR/waybar/scripts" -type f -name "*.py" -exec chmod +x {} + 2>/dev/null
success "Permissions secured."

echo ""
echo -e "${GREEN}==========================================================${RESET}"
success "Installation Complete! 🚀"
info "Next Steps:"
echo "  1. Review monitor setup: ~/.config/hypr/conf/monitors.conf"
echo "  2. Reboot and select 'Hyprland' at the login screen."
echo -e "${GREEN}==========================================================${RESET}"
