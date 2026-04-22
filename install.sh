#!/bin/bash

# ==============================================================================
# 🌌 Astraeus Hyprland Installer
# An automated deployment script for a premium Arch Linux environment.
# ==============================================================================

set -e # Exit on error

# --- Configuration -----------------------------------------------------------
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"

# Official Repository Packages
OFFICIAL_PKGS=(
    "hyprland" "waybar" "rofi-wayland" "kitty" "thunar" "mako"
    "hyprlock" "pipewire" "wireplumber" "pamixer" "pavucontrol"
    "brightnessctl" "networkmanager" "nm-connection-editor" "blueman" "acpi"
    "slurp" "grim" "wl-clipboard" "jq" "bc" "socat" "playerctl" "python" "libnotify"
    "xsettingsd" "polkit-kde-agent" "gnome-keyring" "libpulse"
    "ttf-jetbrains-mono-nerd" "noto-fonts" "noto-fonts-emoji" "base-devel" "git"
)

# AUR Packages
AUR_PKGS=(
    "hyprpaper" "hyprsunset" "ttf-font-awesome"
)

# --- Colors & UI --------------------------------------------------------------
BOLD="\e[1m"
GREEN="\e[32m"
BLUE="\e[34m"
RED="\e[31m"
YELLOW="\e[33m"
CYAN="\e[36m"
MAGENTA="\e[35m"
RESET="\e[0m"

# Helper functions for UI
info()    { echo -e "${BLUE}${BOLD}[*]${RESET} ${BLUE}$1${RESET}"; }
success() { echo -e "${GREEN}${BOLD}[+]${RESET} ${GREEN}$1${RESET}"; }
warn()    { echo -e "${YELLOW}${BOLD}[!]${RESET} ${YELLOW}$1${RESET}"; }
error()   { echo -e "${RED}${BOLD}[x]${RESET} ${RED}$1${RESET}"; }
header()  { echo -e "\n${MAGENTA}${BOLD}--- $1 ---${RESET}\n"; }

# --- Banner -------------------------------------------------------------------
show_banner() {
    clear
    echo -e "${CYAN}"
    echo "    ___         __                               "
    echo "   /   |  _____/ /__________ ____  __  _______   "
    echo "  / /| | / ___/ __/ ___/ __ \`/ _ \/ / / / ___/   "
    echo " / ___ |(__  ) /_/ /  / /_/ /  __/ /_/ (__  )    "
    echo "/_/  |_/____/\__/_/   \__,_/\___/\__,_/____/     "
    echo -e "${MAGENTA}         Premium Hyprland Deployment System${RESET}"
    echo "--------------------------------------------------------"
}

# --- Validation ---------------------------------------------------------------
check_os() {
    if [ ! -f /etc/arch-release ]; then
        error "Fatal: This script requires an Arch Linux-based system."
        exit 1
    fi
}

# --- Dependencies -------------------------------------------------------------
sync_packages() {
    header "Synchronizing System"
    
    info "Updating package databases..."
    sudo pacman -Syu --noconfirm
    
    info "Ensuring base development tools are present..."
    sudo pacman -S --needed --noconfirm base-devel git
    
    # Check/Install AUR Helper
    if ! command -v yay &> /dev/null; then
        info "AUR helper 'yay' not found. Installing from source..."
        git clone https://aur.archlinux.org/yay.git /tmp/yay
        (cd /tmp/yay && makepkg -si --noconfirm)
        rm -rf /tmp/yay
    fi
    success "System core synchronized."
}

install_packages() {
    header "Provisioning Environment"
    
    info "Installing official repository packages..."
    sudo pacman -S --needed --noconfirm "${OFFICIAL_PKGS[@]}"
    
    info "Installing AUR packages..."
    yay -S --needed --noconfirm "${AUR_PKGS[@]}"
    
    success "All dependencies satisfied."
}

# --- Configuration -----------------------------------------------------------
setup_configs() {
    header "Deploying Configurations"
    
    local TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    local BACKUP_PATH="$CONFIG_DIR/backups/astraeus_$TIMESTAMP"
    
    mkdir -p "$BACKUP_PATH"
    
    # Modules to symlink
    local modules=("hypr" "waybar" "rofi" "kitty")
    
    for mod in "${modules[@]}"; do
        local target="$CONFIG_DIR/$mod"
        local source="$DOTFILES_DIR/hyprland/$mod"
        
        if [ -e "$target" ]; then
            if [ -L "$target" ]; then
                info "Removing existing symlink: $mod"
                rm "$target"
            else
                info "Backing up existing directory: $mod -> $BACKUP_PATH"
                mv "$target" "$BACKUP_PATH/"
            fi
        fi
        
        info "Linking $mod..."
        ln -sf "$source" "$target"
    done
    
    success "Configurations linked to ~/.config"
}

finalize_permissions() {
    header "Finalizing Permissions"
    
    info "Setting execution bits on scripts..."
    
    # Hyprland scripts
    [ -d "$CONFIG_DIR/hypr/scripts" ] && find "$CONFIG_DIR/hypr/scripts" -type f -name "*.sh" -exec chmod +x {} +
    [ -f "$CONFIG_DIR/hypr/autostart.sh" ] && chmod +x "$CONFIG_DIR/hypr/autostart.sh"
    [ -f "$CONFIG_DIR/hypr/setup_autostart.sh" ] && chmod +x "$CONFIG_DIR/hypr/setup_autostart.sh"
    
    # Waybar scripts
    [ -d "$CONFIG_DIR/waybar/scripts" ] && find "$CONFIG_DIR/waybar/scripts" -type f -name "*.sh" -exec chmod +x {} +
    [ -d "$CONFIG_DIR/waybar/scripts" ] && find "$CONFIG_DIR/waybar/scripts" -type f -name "*.py" -exec chmod +x {} +
    
    success "Environment secured."
}

# --- Main ---------------------------------------------------------------------
main() {
    show_banner
    check_os
    
    echo -e "${CYAN}This script will install all dependencies and link configurations.${RESET}"
    read -p "Are you sure you want to proceed? (y/N): " confirm
    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        info "Installation cancelled by user."
        exit 0
    fi
    
    sync_packages
    install_packages
    setup_configs
    finalize_permissions
    
    echo ""
    echo -e "${GREEN}==========================================================${RESET}"
    success "Astraeus Deployment Complete! 🚀"
    echo -e "\n${BOLD}Next Steps:${RESET}"
    echo "  1. Review monitor config: ~/.config/hypr/conf/monitors.conf"
    echo "  2. Logout and choose 'Hyprland' session."
    echo "  3. Enjoy your new premium desktop!"
    echo -e "${GREEN}==========================================================${RESET}"
}

main "$@"
