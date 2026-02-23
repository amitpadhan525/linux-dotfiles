#!/usr/bin/env bash

rsync -av --delete ~/.config/{hypr,waybar,rofi}/ ~/github/linux-dotfiles/hyprland/
