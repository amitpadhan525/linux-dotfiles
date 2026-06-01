#!/bin/bash
# ----------------------------------------------------- 
# Wallpaper launcher for hyprpaper v0.8.x
#
# Problem: hyprpaper v0.8.x ignores the "wallpaper =" line in the config
# and exits immediately unless a wallpaper is applied via IPC first.
# This script races to apply the wallpaper via IPC as fast as possible.
# ----------------------------------------------------- 

WALLPAPER="/home/amit/.config/hypr/wallpapers/prime2.png"
CONF="/home/amit/.config/hypr/hyprpaper.conf"
LOG="/home/amit/.config/hypr/logs/hyprpaper.log"

exec > "$LOG" 2>&1
echo "--- Wallpaper launcher started: $(date) ---"

# Kill old instance and remove stale socket
killall -q hyprpaper
while pgrep -x hyprpaper > /dev/null; do sleep 0.05; done

SOCK="${XDG_RUNTIME_DIR}/hypr/${HYPRLAND_INSTANCE_SIGNATURE}/.hyprpaper.sock"
rm -f "$SOCK"

# Start hyprpaper in background
hyprpaper -c "$CONF" &

# Tight loop: apply wallpaper via IPC as soon as socket is alive
for i in $(seq 1 100); do
    result=$(hyprctl hyprpaper wallpaper "eDP-1,$WALLPAPER" 2>&1)
    if [ -z "$result" ]; then
        echo "Wallpaper set on attempt $i"
        break
    fi
    sleep 0.05
done

if pgrep -x hyprpaper > /dev/null; then
    echo "hyprpaper is running. Done."
else
    echo "ERROR: hyprpaper failed to stay alive."
fi

date >> "/home/amit/.config/hypr/logs/wallpaper_script.log"
