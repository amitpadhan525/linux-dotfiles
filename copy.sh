#!/usr/bin/env bash

# Resolve the directory where this script is located
readonly DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Ensure destination directories exist
mkdir -p "$DOTFILES_DIR/hyprland/bash"
mkdir -p "$DOTFILES_DIR/hyprland/git"
mkdir -p "$DOTFILES_DIR/hyprland/systemd/user"

# Core configs (already managed)
rsync -av --delete "$HOME/.config/hypr/" "$DOTFILES_DIR/hyprland/hypr"
rsync -av --delete "$HOME/.config/waybar/" "$DOTFILES_DIR/hyprland/waybar"
rsync -av --delete "$HOME/.config/rofi/" "$DOTFILES_DIR/hyprland/rofi"
rsync -av --delete "$HOME/.config/kitty/" "$DOTFILES_DIR/hyprland/kitty"

# New configs to manage
rsync -av --delete "$HOME/.config/dunst/" "$DOTFILES_DIR/hyprland/dunst"
rsync -av --delete "$HOME/.config/mako/" "$DOTFILES_DIR/hyprland/mako"
rsync -av --delete "$HOME/.config/nwg-dock-hyprland/" "$DOTFILES_DIR/hyprland/nwg-dock-hyprland"
rsync -av --delete "$HOME/.config/nwg-look/" "$DOTFILES_DIR/hyprland/nwg-look"
rsync -av --delete "$HOME/.config/hyprfm/" "$DOTFILES_DIR/hyprland/hyprfm"
rsync -av --delete "$HOME/.config/gtk-3.0/" "$DOTFILES_DIR/hyprland/gtk-3.0"
rsync -av --delete "$HOME/.config/gtk-4.0/" "$DOTFILES_DIR/hyprland/gtk-4.0"
rsync -av --delete "$HOME/.config/xsettingsd/" "$DOTFILES_DIR/hyprland/xsettingsd"
rsync -av --delete "$HOME/.config/systemd/user/" "$DOTFILES_DIR/hyprland/systemd/user"

# Shell & Git configs
rsync -av "$HOME/.bashrc" "$DOTFILES_DIR/hyprland/bash/bashrc"
rsync -av "$HOME/.bash_profile" "$DOTFILES_DIR/hyprland/bash/bash_profile"
rsync -av "$HOME/.gitconfig" "$DOTFILES_DIR/hyprland/git/gitconfig"
