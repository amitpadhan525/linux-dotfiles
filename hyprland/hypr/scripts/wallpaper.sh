#!/bin/bash
# ----------------------------------------------------- 
# Robust Wallpaper Script for Hyprland
# ----------------------------------------------------- 

# Force kill any existing instances to prevent conflicts
killall -9 hyprpaper 2>/dev/null

# Wait a moment for the system/monitors to settle
sleep 1

# Check if the config file exists
CONFIG="/home/amit/.config/hypr/hyprpaper.conf"
if [ ! -f "$CONFIG" ]; then
    echo "Error: Config file not found at $CONFIG"
    exit 1
fi

# Start hyprpaper with absolute path to config
/usr/bin/hyprpaper -c "$CONFIG" &

# Log status
echo "hyprpaper started with config $CONFIG"
