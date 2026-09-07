#!/usr/bin/env bash

# ==============================================================================
# 🌌 Astraeus Hyprland Uninstaller / Rollback System
# Cleanly remove deployed symlinks and optionally restore backups.
# Developed with precision, modern error safety, and truecolor aesthetics.
# ==============================================================================

# --- Safety & Environment -----------------------------------------------------
set -euo pipefail
IFS=$'\n\t'

# --- Configuration & Paths ----------------------------------------------------
readonly DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly CONFIG_DIR="$HOME/.config"
readonly BACKUP_DIR="$CONFIG_DIR/backups"

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
RESTORE_BACKUP=false
REMOVE_BACKUPS=false
DRY_RUN=false

# --- Logging & UI Helpers -----------------------------------------------------
info()    { echo -e "${BLUE}${BOLD}[*]${RESET} ${BLUE}$1${RESET}"; }
success() { echo -e "${GREEN}${BOLD}[+]${RESET} ${GREEN}$1${RESET}"; }
warn()    { echo -e "${YELLOW}${BOLD}[!]${RESET} ${YELLOW}$1${RESET}"; }
error()   { echo -e "${RED}${BOLD}[x]${RESET} ${RED}$1${RESET}"; }
header()  { echo -e "\n${MAGENTA}${BOLD}─── $1 ───${RESET}\n"; }
debug()   { if [ "$DRY_RUN" = "true" ]; then echo -e "${GRAY}[DRY-RUN] $1${RESET}"; fi; }

show_banner() {
    clear || true
    echo -e "${CYAN}${BOLD}"
    echo "    █████╗ ███████╗████████╗██████╗  █████╗ ███████╗██╗   ██╗███████╗"
    echo "   ██╔══██╗██╔════╝╚══██╔══╝██╔══██╗██╔══██╗██╔════╝██║   ██║██╔════╝"
    echo "   ███████║███████╗   ██║   ██████╔╝███████║█████╗  ██║   ██║███████╗"
    echo "   ██╔══██║╚════██║   ██║   ██╔══██╗██╔══██║██╔══╝  ██║   ██║╚════██║"
    echo "   ██║  ██║███████║   ██║   ██║  ██║██║  ██║███████╗╚██████╔╝███████║"
    echo "   ╚═╝  ╚═╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚══════╝"
    echo -e "            ${MAGENTA}${BOLD}Hyprland Uninstaller & Rollback Tool${RESET} ${GRAY}|${RESET} ${CYAN}v3.0${RESET}"
    echo -e "${GRAY}-----------------------------------------------------------------------${RESET}"
}

show_help() {
    show_banner
    echo -e "${BOLD}Usage:${RESET} ./uninstall.sh [OPTIONS]"
    echo -e "\n${BOLD}Options:${RESET}"
    echo -e "  ${GREEN}-y, --non-interactive${RESET}   Execute removal without interactive prompts"
    echo -e "  ${GREEN}-r, --restore-backup${RESET}    Automatically restore the latest backups from ~/.config/backups"
    echo -e "  ${GREEN}--purge-backups${RESET}         Delete the ~/.config/backups directory entirely"
    echo -e "  ${GREEN}-d, --dry-run${RESET}           Simulate execution without removing or restoring files"
    echo -e "  ${GREEN}-h, --help${RESET}              Display this help overview"
    echo -e "\n${GRAY}Created with ❤️ by Amit Padhan | Licensed under MIT${RESET}"
    exit 0
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -y|--non-interactive) NON_INTERACTIVE=true; shift ;;
            -r|--restore-backup) RESTORE_BACKUP=true; shift ;;
            --purge-backups) REMOVE_BACKUPS=true; shift ;;
            -d|--dry-run) DRY_RUN=true; shift ;;
            -h|--help) show_help ;;
            *) error "Unknown option: $1"; echo "Use --help to view options."; exit 1 ;;
        esac
    done
}

remove_symlinks() {
    header "Removing Managed Symlinks"

    local config_modules=("hypr" "waybar" "rofi" "kitty" "dunst" "mako" "nwg-dock-hyprland" "nwg-look" "hyprfm" "gtk-3.0" "gtk-4.0" "xsettingsd" "systemd/user")
    local removed_count=0

    for mod in "${config_modules[@]}"; do
        local target="$CONFIG_DIR/$mod"
        if [ -L "$target" ]; then
            local target_dest
            target_dest="$(readlink "$target" || true)"
            if [[ "$target_dest" == *"$DOTFILES_DIR"* ]]; then
                info "Removing config symlink: ${target#$HOME/}"
                if [ "$DRY_RUN" = "false" ]; then
                    rm "$target"
                fi
                removed_count=$((removed_count + 1))
            else
                debug "Skipping symlink not pointing to this repository: $target"
            fi
        fi
    done

    local home_files=(".bashrc" ".bash_profile" ".gitconfig")
    for file in "${home_files[@]}"; do
        local target="$HOME/$file"
        if [ -L "$target" ]; then
            local target_dest
            target_dest="$(readlink "$target" || true)"
            if [[ "$target_dest" == *"$DOTFILES_DIR"* ]]; then
                info "Removing home file symlink: $file"
                if [ "$DRY_RUN" = "false" ]; then
                    rm "$target"
                fi
                removed_count=$((removed_count + 1))
            else
                debug "Skipping symlink not pointing to this repository: $target"
            fi
        fi
    done

    if [ $removed_count -gt 0 ]; then
        success "Removed $removed_count managed symlink(s)."
    else
        info "No managed symlinks found to remove."
    fi
}

restore_backups() {
    header "Backup Restoration"

    if [ ! -d "$BACKUP_DIR" ]; then
        warn "Backup directory not found: $BACKUP_DIR"
        return 0
    fi

    local config_modules=("hypr" "waybar" "rofi" "kitty" "dunst" "mako" "nwg-dock-hyprland" "nwg-look" "hyprfm" "gtk-3.0" "gtk-4.0" "xsettingsd" "systemd_user" "bashrc" "bash_profile" "gitconfig")
    local restored_count=0

    for mod in "${config_modules[@]}"; do
        # Find latest backup archive matching this module
        local latest_backup
        latest_backup="$(find "$BACKUP_DIR" -maxdepth 1 -name "astraeus_backup_${mod}_*.tar.gz" 2>/dev/null | sort -r | head -n 1 || true)"

        if [ -n "$latest_backup" ] && [ -f "$latest_backup" ]; then
            info "Restoring: $(basename "$latest_backup")"
            if [ "$DRY_RUN" = "false" ]; then
                case "$mod" in
                    bashrc|bash_profile|gitconfig)
                        tar -xzf "$latest_backup" -C "$HOME"
                        ;;
                    systemd_user)
                        mkdir -p "$CONFIG_DIR/systemd"
                        tar -xzf "$latest_backup" -C "$CONFIG_DIR"
                        ;;
                    *)
                        mkdir -p "$CONFIG_DIR"
                        tar -xzf "$latest_backup" -C "$CONFIG_DIR"
                        ;;
                esac
            else
                debug "Would unpack $latest_backup"
            fi
            restored_count=$((restored_count + 1))
        fi
    done

    if [ $restored_count -gt 0 ]; then
        success "Restored $restored_count module backup(s)."
    else
        info "No matching backup archives found to restore."
    fi
}

purge_backups() {
    if [ "$REMOVE_BACKUPS" = "true" ] && [ -d "$BACKUP_DIR" ]; then
        header "Purging Backups"
        info "Removing backup directory: $BACKUP_DIR"
        if [ "$DRY_RUN" = "false" ]; then
            rm -rf "$BACKUP_DIR"
        fi
        success "Backup archives removed."
    fi
}

main() {
    parse_args "$@"
    show_banner

    if [ "$DRY_RUN" = "true" ]; then
        header "Simulation Mode Active"
        info "Running in simulation mode. No modifications will be made."
    fi

    if [ "$NON_INTERACTIVE" = "false" ]; then
        echo -e "${YELLOW}This script will remove the symlinks created by linux-dotfiles.${RESET}\n"
        read -p "  Proceed with uninstall? (y/N): " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            warn "Uninstall aborted by user."
            exit 0
        fi

        if [ "$RESTORE_BACKUP" = "false" ] && [ -d "$BACKUP_DIR" ]; then
            read -p "  Would you like to restore pre-installation backups from ~/.config/backups? (y/N): " -n 1 -r
            echo ""
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                RESTORE_BACKUP=true
            fi
        fi
    fi

    remove_symlinks

    if [ "$RESTORE_BACKUP" = "true" ]; then
        restore_backups
    fi

    purge_backups

    echo -e "\n${GREEN}${BOLD}=======================================================================${RESET}"
    echo -e "${GREEN}${BOLD}   🌌 Astraeus Dotfiles Uninstalled Successfully!${RESET}"
    echo -e "${GREEN}${BOLD}=======================================================================${RESET}\n"
}

main "$@"
