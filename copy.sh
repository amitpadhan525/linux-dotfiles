#!/usr/bin/env bash

rsync -av --delete ~/.config/hypr/ ~/github/linux-dotfiles/hyprland/hypr
rsync -av --delete ~/.config/waybar/ ~/github/linux-dotfiles/hyprland/waybar
rsync -av --delete ~/.config/rofi/ ~/github/linux-dotfiles/hyprland/rofi
rsync -av --delete ~/.config/kitty/ ~/github/linux-dotfiles/hyprland/kitty

