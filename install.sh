#!/usr/bin/env bash

# ==============================================================================
# 🌌 Astraeus Hyprland Installer
# A premium, automated deployment script for a high-performance Arch environment.
# Developed with precision and aesthetic focus.
# ==============================================================================

# --- Safety & Environment -----------------------------------------------------
set -euo pipefail

# --- Configuration -----------------------------------------------------------
readonly DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly CONFIG_DIR="$HOME/.config"
readonly BACKUP_DIR="$CONFIG_DIR/backups/astraeus_$(date +%Y%m%d_%H%M%S)"

# Official Repository Packages
readonly OFFICIAL_PKGS=(
    "hyprland" "waybar" "rofi-wayland" "kitty" "thunar" "mako"
    "hyprlock" "pipewire" "wireplumber" "pamixer" "pavucontrol"
    "brightnessctl" "networkmanager" "nm-connection-editor" "blueman" "acpi"
    "slurp" "grim" "wl-clipboard" "jq" "bc" "socat" "playerctl" "python" "libnotify"
    "xsettingsd" "polkit-kde-agent" "gnome-keyring" "libpulse"
    "ttf-jetbrains-mono-nerd" "noto-fonts" "noto-fonts-emoji" "base-devel" "git"
)

# AUR Packages
readonly AUR_PKGS=(
    "hyprpaper" "hyprsunset" "ttf-font-awesome"
)

# --- Colors & Aesthetics ------------------------------------------------------
readonly BOLD="\e[1m"
readonly GREEN="\e[32m"
readonly BLUE="\e[34m"
readonly RED="\e[31m"
readonly YELLOW="\e[33m"
readonly CYAN="\e[36m"
readonly MAGENTA="\e[35m"
readonly RESET="\e[0m"

# UI Helper functions
info()    { echo -e "${BLUE}${BOLD}[*]${RESET} ${BLUE}$1${RESET}"; }
success() { echo -e "${GREEN}${BOLD}[+]${RESET} ${GREEN}$1${RESET}"; }
warn()    { echo -e "${YELLOW}${BOLD}[!]${RESET} ${YELLOW}$1${RESET}"; }
error()   { echo -e "${RED}${BOLD}[x]${RESET} ${RED}$1${RESET}"; }
header()  { echo -e "\n${MAGENTA}${BOLD}─── $1 ───${RESET}\n"; }

# --- Error Handling -----------------------------------------------------------
cleanup() {
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        echo -e "\n"
        error "Installation failed with exit code $exit_code."
        error "Check the output above for details."
    fi
}
trap cleanup EXIT

# --- Components ---------------------------------------------------------------

show_banner() {
    clear
    echo -e "${CYAN}${BOLD}"
    echo "    █████╗ ███████╗████████╗██████╗  █████╗ ███████╗██╗   ██╗███████╗"
    echo "   ██╔══██╗██╔════╝╚══██╔══╝██╔══██╗██╔══██╗██╔════╝██║   ██║██╔════╝"
    echo "   ███████║███████╗   ██║   ██████╔╝███████║█████╗  ██║   ██║███████╗"
    echo "   ██╔══██║╚════██║   ██║   ██╔══██╗██╔══██║██╔══╝  ██║   ██║╚════██║"
    echo "   ██║  ██║███████║   ██║   ██║  ██║██║  ██║███████╗╚██████╔╝███████║"
    echo "   ╚═╝  ╚═╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚══════╝"
    echo -e "${MAGENTA}             Premium Hyprland Deployment System | v2.0${RESET}"
    echo -e "${BLUE}-----------------------------------------------------------------------${RESET}"
}

check_env() {
    header "System Validation"
    
    if [ ! -f /etc/arch-release ]; then
        error "Fatal: This script requires an Arch Linux-based system."
        exit 1
    fi
    success "Arch Linux detected."

    if ! ping -c 1 google.com &>/dev/null; then
        error "Fatal: No internet connection detected."
        exit 1
    fi
    success "Internet connection verified."
}

sync_system() {
    header "Syncing Package Databases"
    
    info "Refreshing pacman repositories..."
    sudo pacman -Syu --noconfirm
    
    info "Ensuring development toolchain is present..."
    sudo pacman -S --needed --noconfirm base-devel git
    
    # AUR Helper check/install
    if ! command -v yay &> /dev/null; then
        warn "'yay' not found. Installing from source..."
        local temp_dir
        temp_dir=$(mktemp -d)
        git clone https://aur.archlinux.org/yay.git "$temp_dir"
        (cd "$temp_dir" && makepkg -si --noconfirm)
        rm -rf "$temp_dir"
        success "yay installed successfully."
    else
        success "AUR helper 'yay' detected."
    fi
}

install_dependencies() {
    header "Environment Provisioning"
    
    info "Installing official repository packages..."
    sudo pacman -S --needed --noconfirm "${OFFICIAL_PKGS[@]}"
    
    info "Installing AUR packages via yay..."
    yay -S --needed --noconfirm "${AUR_PKGS[@]}"
    
    success "All system dependencies are now satisfied."
}

deploy_configs() {
    header "Deploying Configurations"
    
    info "Preparing backup directory: ${BACKUP_DIR#$HOME/}"
    mkdir -p "$BACKUP_DIR"
    
    # Modules to symlink from hyprland/ directory
    local modules=("hypr" "waybar" "rofi" "kitty")
    
    for mod in "${modules[@]}"; do
        local target="$CONFIG_DIR/$mod"
        local source="$DOTFILES_DIR/hyprland/$mod"
        
        if [ ! -d "$source" ]; then
            warn "Module source not found: $mod. Skipping..."
            continue
        fi

        if [ -e "$target" ]; then
            if [ -L "$target" ]; then
                info "Removing existing symlink: $mod"
                rm "$target"
            else
                info "Backing up existing directory: $mod"
                mv "$target" "$BACKUP_DIR/"
            fi
        fi
        
        info "Linking module: $mod"
        ln -sf "$source" "$target"
    done
    
    success "Configurations successfully linked to ~/.config"
}

finalize_system() {
    header "System Polishing"
    
    info "Applying execution permissions to scripts..."
    
    # Hyprland specific scripts
    if [ -d "$CONFIG_DIR/hypr/scripts" ]; then
        find "$CONFIG_DIR/hypr/scripts" -type f -name "*.sh" -exec chmod +x {} +
    fi
    
    # Global entry points
    local entry_scripts=("autostart.sh" "setup_autostart.sh")
    for script in "${entry_scripts[@]}"; do
        [ -f "$CONFIG_DIR/hypr/$script" ] && chmod +x "$CONFIG_DIR/hypr/$script"
    done
    
    # Waybar scripts
    if [ -d "$CONFIG_DIR/waybar/scripts" ]; then
        find "$CONFIG_DIR/waybar/scripts" -type f \( -name "*.sh" -o -name "*.py" \) -exec chmod +x {} +
    fi
    
    success "System permissions finalized."
}

# --- Execution ----------------------------------------------------------------

main() {
    show_banner
    check_env
    
    echo -e "${CYAN}This orchestration script will perform a full system deployment.${RESET}"
    echo -e "${CYAN}It will sync databases, install packages, and link configurations.${RESET}\n"
    
    read -p "  Proceed with installation? (y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo ""
        warn "Installation aborted by user."
        exit 0
    fi
    
    sync_system
    install_dependencies
    deploy_configs
    finalize_system
    
    echo -e "\n${GREEN}${BOLD}=======================================================================${RESET}"
    echo -e "${GREEN}${BOLD}   🌌 Astraeus Deployment Successful! 🚀${RESET}"
    echo -e "${GREEN}${BOLD}=======================================================================${RESET}"
    
    echo -e "\n${BOLD}Post-Installation Guide:${RESET}"
    echo -e "  ${BLUE}1.${RESET} Review display settings: ${BOLD}~/.config/hypr/conf/monitors.conf${RESET}"
    echo -e "  ${BLUE}2.${RESET} Logout and select the ${CYAN}Hyprland${RESET} session."
    echo -e "  ${BLUE}3.${RESET} Press ${BOLD}Super + Enter${RESET} to launch your terminal."
    echo -e "  ${BLUE}4.${RESET} Explore the keybindings in ${BOLD}README.md${RESET}."
    
    echo -e "\n${MAGENTA}Welcome to your premium desktop experience.${RESET}\n"
}

main "$@"
