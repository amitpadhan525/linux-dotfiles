#!/usr/bin/env bash

# ==============================================================================
# 🧪 Automated Test Suite for Astraeus Install & Update Scripts
# ==============================================================================
set -euo pipefail
IFS=$'\n\t'

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$REPO_DIR"

readonly GREEN="\e[38;2;166;227;161m"
readonly BLUE="\e[38;2;137;180;250m"
readonly RED="\e[38;2;243;139;168m"
readonly MAGENTA="\e[38;2;203;166;247m"
readonly RESET="\e[0m"

log_info()    { echo -e "${BLUE}[*] $1${RESET}"; }
log_success() { echo -e "${GREEN}[+] $1${RESET}"; }
log_error()   { echo -e "${RED}[x] $1${RESET}"; }
header()      { echo -e "\n${MAGENTA}─── $1 ───${RESET}\n"; }

echo -e "\n======================================================="
echo -e "  🧪 Astraeus Deployment & Updater Functional Tests"
echo -e "=======================================================\n"

# 1. Test CLI Help Flags
header "1. CLI Argument Parsing & Help Flags"
log_info "Testing ./install.sh --help..."
./install.sh --help >/dev/null
log_success "./install.sh --help returned exit code 0."

log_info "Testing ./update.sh --help..."
./update.sh --help >/dev/null
log_success "./update.sh --help returned exit code 0."

# 2. Test Dry Run Modes
header "2. Dry Run Simulation"
log_info "Testing ./install.sh -d -y..."
./install.sh -d -y >/dev/null
log_success "./install.sh -d -y executed successfully."

log_info "Testing ./update.sh -d -y -f..."
./update.sh -d -y -f >/dev/null
log_success "./update.sh -d -y -f executed successfully."

# 3. Test Config Deployment in an Isolated Environment
header "3. Functional Config Deployment in Isolated HOME"
TEST_HOME="$(mktemp -d -t astraeus-test-home-XXXXXX)"
export HOME="$TEST_HOME"
trap 'rm -rf "$TEST_HOME"' EXIT

log_info "Isolated test HOME directory: $TEST_HOME"

log_info "Running ./install.sh -c -y -n (configs-only, non-interactive, skip backup)..."
./install.sh -c -y -n >/dev/null
log_success "Installer completed successfully in isolated HOME."

# 4. Verify Symlinks and Destinations
header "4. Verifying Symlink Integrity"
EXPECTED_CONFIG_DIRS=(
    "hypr" "waybar" "rofi" "kitty" "dunst" "mako"
    "nwg-dock-hyprland" "nwg-look" "hyprfm" "gtk-3.0"
    "gtk-4.0" "xsettingsd" "systemd/user"
)

for mod in "${EXPECTED_CONFIG_DIRS[@]}"; do
    target="$TEST_HOME/.config/$mod"
    if [ ! -L "$target" ]; then
        log_error "Missing symlink: $target"
        exit 1
    fi
    if [ ! -d "$target" ]; then
        log_error "Broken symlink or missing target directory: $target -> $(readlink "$target")"
        exit 1
    fi
    log_success "Verified symlink: ~/.config/$mod -> $(readlink "$target")"
done

EXPECTED_HOME_FILES=(
    ".bashrc" ".bash_profile" ".gitconfig"
)

for file in "${EXPECTED_HOME_FILES[@]}"; do
    target="$TEST_HOME/$file"
    if [ ! -L "$target" ]; then
        log_error "Missing home file symlink: $target"
        exit 1
    fi
    if [ ! -f "$target" ]; then
        log_error "Broken symlink or missing target file: $target -> $(readlink "$target")"
        exit 1
    fi
    log_success "Verified home file: ~/$file -> $(readlink "$target")"
done

# 5. Verify Script Permissions
header "5. Verifying Script Execution Bits"
for script in "$TEST_HOME/.config/hypr/scripts"/*.sh; do
    if [ -f "$script" ] && [ ! -x "$script" ]; then
        log_error "Script is not executable: $script"
        exit 1
    fi
done
log_success "All hypr scripts are executable."

for script in "$TEST_HOME/.config/waybar/scripts"/*.sh; do
    if [ -f "$script" ] && [ ! -x "$script" ]; then
        log_error "Script is not executable: $script"
        exit 1
    fi
done
log_success "All waybar scripts are executable."

# 6. Test Update Script in Isolated Environment
header "6. Testing update.sh Redeployment"
log_info "Testing ./update.sh -y -f -n in isolated environment..."
./update.sh -y -f -n >/dev/null
log_success "Updater executed redeployment successfully."

echo -e "\n${GREEN}=======================================================${RESET}"
echo -e "${GREEN}  🎉 All functional tests completed and PASSED! 🚀${RESET}"
echo -e "${GREEN}=======================================================\n"
