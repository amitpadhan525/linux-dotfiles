#!/usr/bin/env bash

rsync -av --delete $HOME/.config/hypr/ $HOME/github/linux-dotfiles/hyprland/hypr
rsync -av --delete $HOME/.config/waybar/ $HOME/github/linux-dotfiles/hyprland/waybar
rsync -av --delete $HOME/.config/rofi/ $HOME/github/linux-dotfiles/hyprland/rofi
rsync -av --delete $HOME/.config/kitty/ $HOME/github/linux-dotfiles/hyprland/kitty

