#!/bin/bash
# ----------------------------------------------------- 
# Robust Wallpaper Script for Hyprland
# ----------------------------------------------------- 

# Force kill any existing instances to prevent conflicts
killall hyprpaper 2>/dev/null

# Wait a moment for the system/monitors to settle
sleep 1

# Start hyprpaper with absolute path to config
/usr/bin/hyprpaper -c /home/amit/.config/hypr/hyprpaper.conf &

echo "hyprpaper started with updated configuration."
