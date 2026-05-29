#!/usr/bin/env bash

# ==============================================================================
# 🌌 Astraeus Hyprland Installer
# A premium, automated deployment script for a high-performance Arch environment.
# Developed with precision, modern error safety, and truecolor aesthetics.
# ==============================================================================

# --- Safety & Environment -----------------------------------------------------
set -euo pipefail
IFS=$'\n\t'

# --- Configuration & Paths ----------------------------------------------------
readonly DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly CONFIG_DIR="$HOME/.config"
readonly BACKUP_DIR="$CONFIG_DIR/backups"

# Categorized Environment Packages
readonly CORE_WM=(
    "hyprland" "hyprpaper" "hyprlock" "hyprsunset"
    "waybar" "rofi-wayland" "kitty" "mako" "dunst" "thunar"
    "nwg-dock-hyprland" "nwg-look"
)
readonly MULTIMEDIA=(
    "pipewire" "pipewire-pulse" "wireplumber" "pamixer" "pavucontrol" "libpulse"
)
readonly SYSTEM_UTILS=(
    "brightnessctl" "networkmanager" "nm-connection-editor" "blueman"
    "acpi" "upower" "slurp" "grim" "wl-clipboard" "jq" "python" "libnotify"
)
readonly SESSION_SERVICES=(
    "wf-recorder" "swaync" "network-manager-applet" "polkit-gnome"
)
readonly PORTAL_SERVICES=(
    "xdg-desktop-portal-hyprland" "xdg-desktop-portal-gtk"
)
readonly DECO_TYPO=(
    "ttf-jetbrains-mono-nerd" "noto-fonts" "noto-fonts-emoji" "ttf-font-awesome"
)
readonly SYSTEM_INTEGRATION=(
    "polkit-kde-agent" "gnome-keyring" "xsettingsd" "base-devel" "git"
)

# Combined Package List
readonly ALL_PKGS=(
    "${CORE_WM[@]}"
    "${MULTIMEDIA[@]}"
    "${SYSTEM_UTILS[@]}"
    "${SESSION_SERVICES[@]}"
    "${PORTAL_SERVICES[@]}"
    "${DECO_TYPO[@]}"
    "${SYSTEM_INTEGRATION[@]}"
)

# --- Catppuccin Mocha Truecolor Palette ---------------------------------------
readonly BOLD="\e[1m"
readonly UNDERLINE="\e[4m"
readonly GREEN="\e[38;2;166;227;161m"   # Mocha Green
readonly BLUE="\e[38;2;137;180;250m"    # Mocha Blue
readonly RED="\e[38;2;243;139;168m"     # Mocha Red
readonly YELLOW="\e[38;2;250;179;135m"  # Mocha Peach
readonly CYAN="\e[38;2;137;220;235m"    # Mocha Sapphire
readonly MAGENTA="\e[38;2;203;166;247m" # Mocha Mauve
readonly GRAY="\e[38;2;108;112;134m"    # Mocha Subtext
readonly RESET="\e[0m"

# --- CLI Defaults -------------------------------------------------------------
NON_INTERACTIVE=false
SKIP_BACKUP=false
PACKAGES_ONLY=false
CONFIGS_ONLY=false
DRY_RUN=false
FORCE=false
AUR_HELPER=""

# --- Logging & UI Helpers -----------------------------------------------------
info()    { echo -e "${BLUE}${BOLD}[*]${RESET} ${BLUE}$1${RESET}"; }
success() { echo -e "${GREEN}${BOLD}[+]${RESET} ${GREEN}$1${RESET}"; }
warn()    { echo -e "${YELLOW}${BOLD}[!]${RESET} ${YELLOW}$1${RESET}"; }
error()   { echo -e "${RED}${BOLD}[x]${RESET} ${RED}$1${RESET}"; }
header()  { echo -e "\n${MAGENTA}${BOLD}─── $1 ───${RESET}\n"; }
debug()   { if [ "$DRY_RUN" = "true" ]; then echo -e "${GRAY}[DRY-RUN] $1${RESET}"; fi; }

# --- Sudo Management ----------------------------------------------------------
SUDO_PID=""

keep_sudo_alive() {
    # Keep-alive sudo loop
    while true; do
        sudo -n true
        sleep 60
        kill -0 "$$" || exit
    done 2>/dev/null &
    SUDO_PID=$!
}

# --- Cleanup & Traps ----------------------------------------------------------
cleanup() {
    local exit_code=$?
    
    # Terminate the sudo refresh background process
    if [[ -n "${SUDO_PID:-}" ]] && ps -p "$SUDO_PID" >/dev/null 2>&1; then
        kill "$SUDO_PID" >/dev/null 2>&1 || true
    fi

    if [ $exit_code -ne 0 ] && [ "$DRY_RUN" = "false" ]; then
        echo -e "\n"
        error "Astraeus Deployment interrupted or failed (Exit Code: $exit_code)."
        error "Check logs or system package manager for errors."
    fi
}
trap cleanup EXIT

# --- Components ---------------------------------------------------------------

show_banner() {
    clear || true
    echo -e "${CYAN}${BOLD}"
    echo "    █████╗ ███████╗████████╗██████╗  █████╗ ███████╗██╗   ██╗███████╗"
    echo "   ██╔══██╗██╔════╝╚══██╔══╝██╔══██╗██╔══██╗██╔════╝██║   ██║██╔════╝"
    echo "   ███████║███████╗   ██║   ██████╔╝███████║█████╗  ██║   ██║███████╗"
    echo "   ██╔══██║╚════██║   ██║   ██╔══██╗██╔══██║██╔══╝  ██║   ██║╚════██║"
    echo "   ██║  ██║███████║   ██║   ██║  ██║██║  ██║███████╗╚██████╔╝███████║"
    echo "   ╚═╝  ╚═╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚══════╝"
    echo -e "             ${MAGENTA}${BOLD}Premium Hyprland Deployment System${RESET} ${GRAY}|${RESET} ${CYAN}v3.0${RESET}"
    echo -e "${GRAY}-----------------------------------------------------------------------${RESET}"
}

show_help() {
    show_banner
    echo -e "${BOLD}Usage:${RESET} ./install.sh [OPTIONS]"
    echo -e "\n${BOLD}Options:${RESET}"
    echo -e "  ${GREEN}-y, --non-interactive${RESET}   Execute script without interactive prompts (auto-accepts default actions)"
    echo -e "  ${GREEN}-n, --no-backup${RESET}         Skip creating a compressed archive of existing configuration files"
    echo -e "  ${GREEN}-p, --packages-only${RESET}     Install/update core packages only, skipping symbolic link creation"
    echo -e "  ${GREEN}-c, --configs-only${RESET}      Deploy symbolic links for configuration folders only, skipping pacman sync"
    echo -e "  ${GREEN}-d, --dry-run${RESET}           Simulate execution of deployment without committing changes to disk"
    echo -e "  ${GREEN}-f, --force${RESET}             Overwrite configuration blocks and bypass sanity assertions"
    echo -e "  ${GREEN}-h, --help${RESET}              Display this premium help configuration overview"
    echo -e "\n${GRAY}Created with ❤️ by Amit Padhan | Licensed under MIT${RESET}"
    exit 0
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -y|--non-interactive) NON_INTERACTIVE=true; shift ;;
            -n|--no-backup) SKIP_BACKUP=true; shift ;;
            -p|--packages-only) PACKAGES_ONLY=true; shift ;;
            -c|--configs-only) CONFIGS_ONLY=true; shift ;;
            -d|--dry-run) DRY_RUN=true; shift ;;
            -f|--force) FORCE=true; shift ;;
            -h|--help) show_help ;;
            *) error "Unknown command line option: $1"; echo "Use --help to view arguments."; exit 1 ;;
        esac
    done
}

check_env() {
    header "System Validation"
    
    # 1. Do not run as root directly
    if [ "$EUID" -eq 0 ]; then
        error "Fatal: Do not run this installer script with sudo or as root directly."
        error "Run as a normal user. The script will request elevation when executing pacman commands."
        exit 1
    fi
    success "Non-root context verified."

    # 2. Check if running on Arch Linux
    if [ ! -f /etc/arch-release ] && [ ! -f /etc/os-release ]; then
        error "Fatal: This deployment script requires an Arch Linux-based distribution."
        exit 1
    fi
    # shellcheck disable=SC1091
    . /etc/os-release
    if [[ "${ID:-}" != "arch" && "${ID_LIKE:-}" != *"arch"* ]]; then
        error "Fatal: This deployment script requires Arch Linux or an Arch-based distribution."
        exit 1
    fi
    success "Arch Linux system architecture detected."

    # 3. Check for internet connectivity
    info "Verifying internet connectivity..."
    local domains=("archlinux.org" "github.com" "aur.archlinux.org")
    local connected=false
    for domain in "${domains[@]}"; do
        if timeout 3 bash -c "exec 3<>/dev/tcp/$domain/443" &>/dev/null; then
            connected=true
            break
        fi
    done
    
    if [ "$connected" = "false" ]; then
        error "Fatal: No active internet connection detected."
        error "Please connect to a network and re-run the script."
        exit 1
    fi
    success "Internet connection verified."

    # 4. Check for pacman lock
    if [ -f /var/lib/pacman/db.lck ]; then
        warn "Warning: Pacman database lock detected (/var/lib/pacman/db.lck)."
        if [ "$FORCE" = "true" ]; then
            info "Force flag enabled. Removing pacman lock..."
            if [ "$DRY_RUN" = "false" ]; then
                sudo rm /var/lib/pacman/db.lck
            fi
        else
            error "Fatal: Pacman is currently locked by another process."
            error "Please close other package managers and release the lock, or run with --force."
            exit 1
        fi
    fi
    
    # 5. Acquire sudo privileges once before starting the banner flow
    info "Requesting sudo permissions for system package management..."
    if [ "$DRY_RUN" = "false" ]; then
        sudo -v
        keep_sudo_alive
    fi
    success "Administrative privileges acquired and locked."
}

detect_aur_helper() {
    header "AUR Helper Check"
    
    if command -v yay &>/dev/null; then
        AUR_HELPER="yay"
        success "Detected AUR helper: yay"
    elif command -v paru &>/dev/null; then
        AUR_HELPER="paru"
        success "Detected AUR helper: paru"
    else
        warn "No AUR helper (yay/paru) detected in search path."
        
        if [ "$NON_INTERACTIVE" = "true" ]; then
            info "Non-interactive mode: Bootstrapping 'yay-bin' automatically..."
            install_bootstrap_dependencies
            bootstrap_yay
        else
            read -p "  Would you like to install 'yay' now? (Y/n): " -n 1 -r
            echo ""
            if [[ $REPLY =~ ^[Nn]$ ]]; then
                warn "Skipping AUR helper installation. AUR package support will be unavailable."
            else
                install_bootstrap_dependencies
                bootstrap_yay
            fi
        fi
    fi
}

install_bootstrap_dependencies() {
    header "Bootstrap Dependencies"

    info "Ensuring the minimal build tools required for AUR bootstrap are available..."
    if [ "$DRY_RUN" = "false" ]; then
        sudo pacman -S --needed --noconfirm git base-devel
    else
        debug "Would install bootstrap tools: git base-devel"
    fi
    success "Bootstrap dependencies are ready."
}

bootstrap_yay() {
    info "Preparing build environment for yay-bin..."
    local temp_build_dir
    temp_build_dir=$(mktemp -d)
    
    debug "Created temporary build path: $temp_build_dir"
    
    if [ "$DRY_RUN" = "false" ]; then
        git clone https://aur.archlinux.org/yay-bin.git "$temp_build_dir"
        (
            cd "$temp_build_dir"
            makepkg -si --noconfirm
        )
        rm -rf "$temp_build_dir"
        AUR_HELPER="yay"
    fi
    success "yay has been successfully installed and registered as the primary AUR provider."
}

sync_system() {
    header "Database Synchronization"
    
    info "Syncing local databases and performing complete system upgrade..."
    if [ "$DRY_RUN" = "false" ]; then
        sudo pacman -Syu --noconfirm
    else
        debug "Would run: sudo pacman -Syu --noconfirm"
    fi
    success "System package databases successfully synchronized."
}

install_packages() {
    header "Package Provisioning"
    
    info "Resolving system packages from official repositories..."
    if [ "$DRY_RUN" = "false" ]; then
        local to_install_official=()
        local to_install_aur=()

        for pkg in "${ALL_PKGS[@]}"; do
            if pacman -Si "$pkg" >/dev/null 2>&1; then
                to_install_official+=("$pkg")
            else
                to_install_aur+=("$pkg")
            fi
        done

        if [ ${#to_install_official[@]} -gt 0 ]; then
            info "Installing official repo packages: ${to_install_official[*]}"
            sudo pacman -S --needed --noconfirm "${to_install_official[@]}"
        else
            info "No official repository packages to install."
        fi

        if [ ${#to_install_aur[@]} -gt 0 ]; then
            if [ -n "$AUR_HELPER" ] && command -v "$AUR_HELPER" >/dev/null 2>&1; then
                info "Installing AUR packages via $AUR_HELPER: ${to_install_aur[*]}"
                "$AUR_HELPER" -S --needed --noconfirm "${to_install_aur[@]}"
            else
                warn "AUR packages detected but no AUR helper available. Skipping: ${to_install_aur[*]}"
            fi
        else
            info "No AUR packages detected."
        fi
    else
        debug "Would resolve and install packages: ${ALL_PKGS[*]}"
    fi
    success "Package provisioning step completed."
}

deploy_configs() {
    header "Config Orchestration"
    
    # 1. Handle Backup operations
    if [ "$SKIP_BACKUP" = "false" ]; then
        info "Configuring archival directories..."
        if [ "$DRY_RUN" = "false" ]; then
            mkdir -p "$BACKUP_DIR"
        fi
        
        local modules=("hypr" "waybar" "rofi" "kitty" "dunst" "mako" "nwg-dock-hyprland" "nwg-look" "gtk-3.0" "gtk-4.0" "xsettingsd" "systemd/user")
        local backed_up_count=0
        
        for mod in "${modules[@]}"; do
            local target="$CONFIG_DIR/$mod"
            
            if [ -d "$target" ]; then
                if [ -L "$target" ]; then
                    debug "Removing existing configuration symbolic link: ${target#$HOME/}"
                    if [ "$DRY_RUN" = "false" ]; then
                        rm "$target"
                    fi
                else
                    local archive_file="astraeus_backup_${mod//\//_}_$(date +%Y%m%d_%H%M%S).tar.gz"
                    info "Creating secure archive: ${target#$HOME/} -> $archive_file"
                    if [ "$DRY_RUN" = "false" ]; then
                        tar -czf "$BACKUP_DIR/$archive_file" -C "$CONFIG_DIR" "$mod"
                        rm -rf "$target"
                    fi
                    backed_up_count=$((backed_up_count + 1))
                fi
            elif [ -e "$target" ]; then
                # If it's a file but not a directory
                info "Removing existing non-directory block: ${target#$HOME/}"
                if [ "$DRY_RUN" = "false" ]; then
                    rm -f "$target"
                fi
            fi
        done
        
        if [ $backed_up_count -gt 0 ]; then
            success "Archived existing folders inside: ${BACKUP_DIR#$HOME/}"
        else
            success "No directories required archival backup."
        fi
    else
        warn "Skipping configuration archival backup (Skip flag enabled)."
    fi

    # 2. Handle Symbolic Linking
    info "Deploying symbolic links..."
    
    if [ "$DRY_RUN" = "false" ]; then
        mkdir -p "$CONFIG_DIR"
    fi
    
    local config_modules=("hypr" "waybar" "rofi" "kitty" "dunst" "mako" "nwg-dock-hyprland" "nwg-look" "gtk-3.0" "gtk-4.0" "xsettingsd" "systemd/user")
    
    for mod in "${config_modules[@]}"; do
        local source="$DOTFILES_DIR/hyprland/$mod"
        local target="$CONFIG_DIR/$mod"
        
        if [ ! -d "$source" ]; then
            error "Deployment module source not found: $source"
            continue
        fi
        
        info "Linking module: ${mod} -> ${target#$HOME/}"
        if [ "$DRY_RUN" = "false" ]; then
            # Clean up trailing file/links to avoid nesting links
            rm -rf "$target"
            mkdir -p "$(dirname "$target")"
            ln -snf "$source" "$target"
        else
            debug "Would execute: ln -snf $source $target"
        fi
    done
    
    success "Symbolic configurations mapped cleanly to $CONFIG_DIR"

    # 3. Handle Home-level Dotfiles
    info "Deploying home-level dotfiles..."
    
    local home_files=(
        "bash/bashrc:.bashrc"
        "bash/bash_profile:.bash_profile"
        "git/gitconfig:.gitconfig"
    )
    
    for item in "${home_files[@]}"; do
        local source_rel="${item%%:*}"
        local target_name="${item#*:}"
        local source="$DOTFILES_DIR/hyprland/$source_rel"
        local target="$HOME/$target_name"
        
        if [ ! -f "$source" ]; then
            error "Home file source not found: $source"
            continue
        fi
        
        if [ "$SKIP_BACKUP" = "false" ] && [ -f "$target" ] && [ ! -L "$target" ]; then
            local archive_file="astraeus_backup_${target_name#.}_$(date +%Y%m%d_%H%M%S).tar.gz"
            info "Archiving existing home file: $target_name -> $archive_file"
            if [ "$DRY_RUN" = "false" ]; then
                tar -czf "$BACKUP_DIR/$archive_file" -C "$HOME" "$target_name"
                rm -f "$target"
            fi
        elif [ -e "$target" ]; then
            if [ "$DRY_RUN" = "false" ]; then
                rm -rf "$target"
            fi
        fi
        
        info "Linking home file: $target_name -> ${target#$HOME/}"
        if [ "$DRY_RUN" = "false" ]; then
            ln -snf "$source" "$target"
        else
            debug "Would execute: ln -snf $source $target"
        fi
    done
    
    success "Home-level dotfiles linked cleanly to $HOME"
}

finalize_system() {
    header "Permissions & System Finishing"
    
    info "Resolving file permissions on executable scripts..."
    
    if [ "$DRY_RUN" = "false" ]; then
        # 1. Hyprland Internal Utility scripts
        if [ -d "$CONFIG_DIR/hypr/scripts" ]; then
            find "$CONFIG_DIR/hypr/scripts" -type f -name "*.sh" -exec chmod +x {} +
            debug "Applied executable bit to all shell scripts in $CONFIG_DIR/hypr/scripts"
        fi
        
        # 2. Waybar telemetry and script backends
        if [ -d "$CONFIG_DIR/waybar/scripts" ]; then
            find "$CONFIG_DIR/waybar/scripts" -type f \( -name "*.sh" -o -name "*.py" \) -exec chmod +x {} +
            debug "Applied executable bit to all shell & python scripts in $CONFIG_DIR/waybar/scripts"
        fi
        
        # 3. Main copy & push helper scripts in the repository directory
        find "$DOTFILES_DIR" -type f -name "*.sh" -exec chmod +x {} +
        debug "Applied executable bit to local repository utility shell scripts."
    else
        debug "Would apply executable permissions recursively to dotfiles modules."
    fi
    
    success "System execution bits and script permissions resolved."
}

# --- Execution Entrypoint -----------------------------------------------------

main() {
    parse_args "$@"
    show_banner
    check_env
    
    if [ "$DRY_RUN" = "true" ]; then
        header "Simulation Mode Active"
        info "Running in simulation mode. No modifications will be committed."
    fi
    
    if [ "$NON_INTERACTIVE" = "false" ]; then
        echo -e "${CYAN}This orchestration script will perform a complete system deployment.${RESET}"
        echo -e "${CYAN}It will synchronize databases, install dependencies, and link modules.${RESET}\n"
        
        read -p "  Proceed with installation? (y/N): " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            warn "Deployment sequence aborted by user action."
            exit 0
        fi
    fi

    # Trigger steps based on configurations
    if [ "$CONFIGS_ONLY" = "false" ]; then
        detect_aur_helper
        sync_system
        install_packages
    else
        info "Skipping package provisioning steps (Config-only active)."
    fi

    if [ "$PACKAGES_ONLY" = "false" ]; then
        deploy_configs
        finalize_system
    else
        info "Skipping symlink configurations steps (Packages-only active)."
    fi
    
    # Complete
    echo -e "\n${GREEN}${BOLD}=======================================================================${RESET}"
    echo -e "${GREEN}${BOLD}   🌌 Astraeus Deployment Completed Successfully! 🚀${RESET}"
    echo -e "${GREEN}${BOLD}=======================================================================${RESET}"
    
    echo -e "\n${BOLD}Post-Installation Guide & Operations:${RESET}"
    echo -e "  ${BLUE}1.${RESET} Verify your primary monitor setups in: ${BOLD}$HOME/.config/hypr/conf/monitors.lua${RESET}"
    echo -e "  ${BLUE}2.${RESET} Log out of your current display manager and select the ${CYAN}Hyprland${RESET} session."
    echo -e "  ${BLUE}3.${RESET} Spawn Kitty terminal using the custom hotkey: ${BOLD}Super + Enter${RESET}"
    echo -e "  ${BLUE}4.${RESET} Explore all custom hotkeys and mechanics inside ${BOLD}README.md${RESET}."
    
    echo -e "\n${MAGENTA}${BOLD}Welcome to the ultimate desktop orchestration environment!${RESET}\n"
}

main "$@"
