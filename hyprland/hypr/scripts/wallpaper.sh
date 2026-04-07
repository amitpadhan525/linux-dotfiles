#!/bin/bash
# ----------------------------------------------------- 
# Wallpaper Script
# ----------------------------------------------------- 

pkill hyprpaper
sleep 1
hyprpaper &
sleep 2

# Apply wallpaper using IPC
hyprctl hyprpaper wallpaper "eDP-1,/home/amit/.config/hypr/bg.jpg" || true
hyprctl hyprpaper wallpaper "HDMI-A-1,/home/amit/.config/hypr/bg.jpg" || true
