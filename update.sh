#!/usr/bin/env bash

# ==============================================================================
# 🌌 Astraeus Hyprland Update System
# A premium, automated update script for Astraeus configuration deployments.
# Developed with precision, modern error safety, and truecolor aesthetics.
# ==============================================================================

set -euo pipefail
IFS=$'\n\t'

# --- Configuration & Paths ----------------------------------------------------
readonly DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- Catppuccin Mocha Truecolor Palette ---------------------------------------
readonly BOLD="\e[1m"
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
DRY_RUN=false
SYNC_PACKAGES=false
FORCE_DEPLOY=false

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
    echo -e "             ${MAGENTA}${BOLD}Premium Hyprland Config Updater${RESET} ${GRAY}|${RESET} ${CYAN}v3.0${RESET}"
    echo -e "${GRAY}-----------------------------------------------------------------------${RESET}"
}

show_help() {
    show_banner
    echo -e "${BOLD}Usage:${RESET} ./update.sh [OPTIONS]"
    echo -e "\n${BOLD}Options:${RESET}"
    echo -e "  ${GREEN}-y, --non-interactive${RESET}   Execute updates without interactive prompts"
    echo -e "  ${GREEN}-n, --no-backup${RESET}         Skip backup generation during deployment"
    echo -e "  ${GREEN}-p, --packages${RESET}          Check for and install new packages as well"
    echo -e "  ${GREEN}-f, --force${RESET}             Force config deployment even if repository is up-to-date"
    echo -e "  ${GREEN}-d, --dry-run${RESET}           Simulate update sequence without modifying disk files"
    echo -e "  ${GREEN}-h, --help${RESET}              Display this update help overview"
    exit 0
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -y|--non-interactive) NON_INTERACTIVE=true; shift ;;
            -n|--no-backup) SKIP_BACKUP=true; shift ;;
            -p|--packages) SYNC_PACKAGES=true; shift ;;
            -f|--force) FORCE_DEPLOY=true; shift ;;
            -d|--dry-run) DRY_RUN=true; shift ;;
            -h|--help) show_help ;;
            *) error "Unknown option: $1"; echo "Use --help to view options."; exit 1 ;;
        esac
    done
}

check_env() {
    # Verify execution directory
    if [ ! -f "$DOTFILES_DIR/install.sh" ] || [ ! -f "$DOTFILES_DIR/copy.sh" ]; then
        error "Fatal: Script must be run from the root of the linux-dotfiles repository."
        exit 1
    fi

    # Verify Git environment
    if ! command -v git &>/dev/null; then
        error "Fatal: Git is required to run the update utility."
        exit 1
    fi
}

sync_repo() {
    header "Synchronizing Repository"

    # Check for local modifications
    if [[ -n "$(git status --porcelain)" ]]; then
        warn "Local uncommitted modifications detected in the repository."
        
        if [ "$NON_INTERACTIVE" = "true" ]; then
            info "Non-interactive mode: Stashing local modifications automatically..."
            if [ "$DRY_RUN" = "false" ]; then
                git stash -u
            fi
        else
            read -p "  Would you like to stash your local changes? (Y/n): " -n 1 -r
            echo ""
            if [[ $REPLY =~ ^[Nn]$ ]]; then
                error "Update sequence aborted: please commit or stash changes before updating."
                exit 1
            else
                info "Stashing local changes..."
                if [ "$DRY_RUN" = "false" ]; then
                    git stash -u
                fi
            fi
        fi
    fi

    # Fetch updates from origin
    info "Fetching updates from GitHub repository..."
    if [ "$DRY_RUN" = "false" ]; then
        git fetch origin main
    else
        debug "Would run: git fetch origin main"
    fi

    local current_branch
    current_branch=$(git rev-parse --abbrev-ref HEAD)
    
    # Check if local is behind remote
    local local_sha remote_sha base_sha
    local_sha=$(git rev-parse HEAD)
    
    if [ "$DRY_RUN" = "false" ]; then
        remote_sha=$(git rev-parse "origin/main")
        base_sha=$(git merge-base HEAD "origin/main")
    else
        remote_sha="$local_sha"
        base_sha="$local_sha"
    fi

    if [ "$local_sha" = "$remote_sha" ]; then
        success "Repository is already up-to-date with upstream (origin/main)."
        if [ "$FORCE_DEPLOY" = "false" ]; then
            if [ "$NON_INTERACTIVE" = "false" ]; then
                read -p "  Redeploy/refresh configurations anyway? (y/N): " -n 1 -r
                echo ""
                if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                    success "Update completed. No redeployment requested."
                    exit 0
                fi
            else
                info "Up-to-date. Skipping redeployment. Use --force or -f to override."
                exit 0
            fi
        fi
    elif [ "$local_sha" = "$base_sha" ]; then
        info "New updates detected! Pulling latest changes..."
        if [ "$DRY_RUN" = "false" ]; then
            git pull origin "$current_branch"
        else
            debug "Would run: git pull origin $current_branch"
        fi
        success "Local repository updated successfully."
    else
        warn "Your local repository has diverged from origin/main."
        if [ "$FORCE_DEPLOY" = "false" ]; then
            error "Aborting automatic update to prevent conflict. Resolve git conflicts manually."
            exit 1
        fi
    fi
}

redeploy_configs() {
    header "Redeploying Configurations"

    # Forward configurations to install.sh
    local flags=()
    if [ "$NON_INTERACTIVE" = "true" ]; then flags+=("-y"); fi
    if [ "$SKIP_BACKUP" = "true" ]; then flags+=("-n"); fi
    if [ "$DRY_RUN" = "true" ]; then flags+=("-d"); fi
    if [ "$SYNC_PACKAGES" = "false" ]; then flags+=("-c"); fi

    info "Forwarding sync deployment to install.sh with options: ${flags[*]:-default}"
    
    # Execute installer
    ./install.sh "${flags[@]}"
}

reload_environment() {
    header "Applying Changes"
    
    if [ "$DRY_RUN" = "true" ]; then
        debug "Would reload Hyprland configs using: hyprctl reload"
        debug "Would refresh Waybar status panels"
        debug "Would reload Dunst notification layout"
        return
    fi

    # 1. Reload Hyprland configuration
    if pgrep -x hyprland >/dev/null; then
        info "Hot-reloading Hyprland..."
        hyprctl reload || true
        success "Hyprland reloaded."
    fi

    # 2. Reload Waybar
    if pgrep -x waybar >/dev/null; then
        info "Refreshing Waybar status bar..."
        pkill -USR2 waybar || true
        success "Waybar refreshed."
    fi

    # 3. Reload Dunst
    if pgrep -x dunst >/dev/null; then
        info "Reloading Dunst notification manager..."
        dunstctl reload || true
        success "Dunst reloaded."
    fi
}

main() {
    parse_args "$@"
    show_banner
    check_env
    sync_repo
    redeploy_configs
    reload_environment
    
    echo -e "\n${GREEN}${BOLD}=======================================================================${RESET}"
    echo -e "${GREEN}${BOLD}   🌌 Astraeus System Configurations Updated Successfully! 🚀${RESET}"
    echo -e "${GREEN}${BOLD}=======================================================================${RESET}\n"
}

main "$@"
