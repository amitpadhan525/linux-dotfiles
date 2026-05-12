#!/bin/bash
# ----------------------------------------------------- 
# IPC-Based Wallpaper Script (Final Robust Version)
# ----------------------------------------------------- 

LOG="/home/amit/.config/hypr/logs/hyprpaper.log"
WALLPAPER="/home/amit/Pictures/prime2.png"

# Redirect all output to log
exec > "$LOG" 2>&1

echo "--- Starting IPC Wallpaper Script ---"
date

# Kill existing instances
/usr/bin/killall hyprpaper 2>/dev/null
sleep 1

# Start hyprpaper with a minimal config
echo "splash = false" > /tmp/hyprpaper_minimal.conf
echo "ipc = on" >> /tmp/hyprpaper_minimal.conf
/usr/bin/hyprpaper -c /tmp/hyprpaper_minimal.conf &

# Wait for hyprpaper to initialize and see monitors
sleep 3

# Preload the wallpaper
echo "Preloading $WALLPAPER..."
hyprctl hyprpaper preload "$WALLPAPER"
sleep 1

# Detect monitors and apply via IPC
MONITORS=$(hyprctl monitors | grep "Monitor" | awk '{print $2}')
echo "Detected monitors: $MONITORS"

if [ -z "$MONITORS" ]; then
    echo "No monitors detected, using catch-all."
    hyprctl hyprpaper wallpaper ",$WALLPAPER"
else
    for m in $MONITORS; do
        echo "Applying to monitor via IPC: $m"
        hyprctl hyprpaper wallpaper "$m,$WALLPAPER"
    done
    # Also apply catch-all for any new monitors
    hyprctl hyprpaper wallpaper ",$WALLPAPER"
fi

echo "Wallpaper applied successfully."
date >> "/home/amit/.config/hypr/logs/wallpaper_script.log"
