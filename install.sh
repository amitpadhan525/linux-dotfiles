#!/bin/bash

# =======================================================================
# Arch Linux Dotfiles Installer
# =======================================================================

# Configuration and variables
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"

# Core and Utility Packages (Official Repositories)
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

# Output Colors
GREEN="\e[32m"
BLUE="\e[34m"
RED="\e[31m"
YELLOW="\e[33m"
RESET="\e[0m"

# Helper functions
info() { echo -e "${BLUE}[*] $1${RESET}"; }
success() { echo -e "${GREEN}[+] $1${RESET}"; }
warn() { echo -e "${YELLOW}[!] $1${RESET}"; }
error() { echo -e "${RED}[x] $1${RESET}"; }

echo -e "${GREEN}"
echo "    __  __                     __                 __  "
echo "   / / / /_  ______  _____/ /___ _____  ____/ /  "
echo "  / /_/ / / / / __ \/ ___/ / __ \`/ __ \/ __  /   "
echo " / __  / /_/ / /_/ / /  / / /_/ / / / / /_/ /    "
echo "/_/ /_/\__, / .___/_/  /_/\__,_/_/ /_/\__,_/_    "
echo "      /____/_/                                   "
echo -e "${RESET}"
echo "Starting installation..."

# 1. OS Check
if [ ! -f /etc/arch-release ]; then
    error "This script is built for Arch Linux-based systems only."
    exit 1
fi
success "Arch Linux detected."

# 2. System Update & Base Requirements
info "Updating system and ensuring base-devel / git are installed..."
sudo pacman -Syu --noconfirm
sudo pacman -S --needed --noconfirm base-devel git

# 3. Check for AUR Helper (yay)
if ! command -v yay &> /dev/null; then
    warn "'yay' AUR helper not found. Installing yay..."
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay || exit
    makepkg -si --noconfirm
    cd "$DOTFILES_DIR" || exit
    rm -rf /tmp/yay
    success "yay installed successfully."
else
    success "yay is already installed."
fi

# 4. Install Official Packages
info "Installing official repository packages..."
for pkg in "${OFFICIAL_PKGS[@]}"; do
    if ! pacman -Qs "^$pkg$" &> /dev/null; then
        info "Installing $pkg..."
        sudo pacman -S --noconfirm "$pkg"
    else
        success "$pkg is already installed."
    fi
done

# 5. Install AUR Packages
info "Installing AUR packages..."
for pkg in "${AUR_PKGS[@]}"; do
    if ! pacman -Qs "^$pkg$" &> /dev/null; then
        info "Installing $pkg (AUR)..."
        yay -S --noconfirm "$pkg"
    else
        success "$pkg is already installed."
    fi
done

# 6. Backup Existing Configurations
info "Backing up existing configurations..."
mkdir -p "$CONFIG_DIR/config-backups_$(date +%Y%m%d)"

backup_config() {
    local target="$1"
    if [ -d "$CONFIG_DIR/$target" ] && [ ! -L "$CONFIG_DIR/$target" ]; then
        mv "$CONFIG_DIR/$target" "$CONFIG_DIR/config-backups_$(date +%Y%m%d)/"
        success "Backed up existing ~/.config/$target"
    elif [ -L "$CONFIG_DIR/$target" ]; then
        rm "$CONFIG_DIR/$target"
        success "Removed existing symlink for $target"
    fi
}

backup_config "hypr"
backup_config "waybar"
backup_config "rofi"
backup_config "kitty"

# 7. Symlink Configurations
info "Applying new configuration files..."
ln -sf "$DOTFILES_DIR/hyprland/hypr" "$CONFIG_DIR/hypr"
ln -sf "$DOTFILES_DIR/hyprland/waybar" "$CONFIG_DIR/waybar"
ln -sf "$DOTFILES_DIR/hyprland/rofi" "$CONFIG_DIR/rofi"
ln -sf "$DOTFILES_DIR/hyprland/kitty" "$CONFIG_DIR/kitty"
success "Configuration files correctly linked."

# 8. Set Execute Permissions
info "Setting execute permissions for hidden scripts..."
chmod +x "$CONFIG_DIR"/hypr/scripts/*.sh 2>/dev/null
chmod +x "$CONFIG_DIR"/hypr/autostart.sh 2>/dev/null
chmod +x "$CONFIG_DIR"/waybar/scripts/*.sh 2>/dev/null
chmod +x "$CONFIG_DIR"/waybar/scripts/*.py 2>/dev/null
success "Permissions secured."

echo ""
success "=========================================================="
success "Installation Complete! 🎉"
success "Please review your monitor settings in ~/.config/hypr/conf/monitors.conf"
success "Reboot your computer and select 'Hyprland' from your login manager."
success "=========================================================="
