#!/usr/bin/env bash

# Ensure destination directories exist
mkdir -p "$HOME/github/linux-dotfiles/hyprland/bash"
mkdir -p "$HOME/github/linux-dotfiles/hyprland/git"
mkdir -p "$HOME/github/linux-dotfiles/hyprland/systemd/user"

# Core configs (already managed)
rsync -av --delete "$HOME/.config/hypr/" "$HOME/github/linux-dotfiles/hyprland/hypr"
rsync -av --delete "$HOME/.config/waybar/" "$HOME/github/linux-dotfiles/hyprland/waybar"
rsync -av --delete "$HOME/.config/rofi/" "$HOME/github/linux-dotfiles/hyprland/rofi"
rsync -av --delete "$HOME/.config/kitty/" "$HOME/github/linux-dotfiles/hyprland/kitty"

# New configs to manage
rsync -av --delete "$HOME/.config/dunst/" "$HOME/github/linux-dotfiles/hyprland/dunst"
rsync -av --delete "$HOME/.config/mako/" "$HOME/github/linux-dotfiles/hyprland/mako"
rsync -av --delete "$HOME/.config/nwg-dock-hyprland/" "$HOME/github/linux-dotfiles/hyprland/nwg-dock-hyprland"
rsync -av --delete "$HOME/.config/nwg-look/" "$HOME/github/linux-dotfiles/hyprland/nwg-look"
rsync -av --delete "$HOME/.config/gtk-3.0/" "$HOME/github/linux-dotfiles/hyprland/gtk-3.0"
rsync -av --delete "$HOME/.config/gtk-4.0/" "$HOME/github/linux-dotfiles/hyprland/gtk-4.0"
rsync -av --delete "$HOME/.config/xsettingsd/" "$HOME/github/linux-dotfiles/hyprland/xsettingsd"
rsync -av --delete "$HOME/.config/systemd/user/" "$HOME/github/linux-dotfiles/hyprland/systemd/user"

# Shell & Git configs
rsync -av "$HOME/.bashrc" "$HOME/github/linux-dotfiles/hyprland/bash/bashrc"
rsync -av "$HOME/.bash_profile" "$HOME/github/linux-dotfiles/hyprland/bash/bash_profile"
rsync -av "$HOME/.gitconfig" "$HOME/github/linux-dotfiles/hyprland/git/gitconfig"
