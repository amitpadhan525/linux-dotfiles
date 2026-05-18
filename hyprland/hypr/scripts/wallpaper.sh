#!/bin/bash
# ----------------------------------------------------- 
# Instant Wallpaper Script
# ----------------------------------------------------- 

LOG="/home/amit/.config/hypr/logs/hyprpaper.log"

# Redirect all output to log
exec > "$LOG" 2>&1

echo "--- Starting Instant Wallpaper Script ---"
date

# Kill existing instances and wait for them to fully die
/usr/bin/killall -q hyprpaper
while pgrep -x hyprpaper >/dev/null; do sleep 0.1; done

# Start hyprpaper natively, disown it so it stays alive, and detach its output
nohup /usr/bin/hyprpaper -c /home/amit/.config/hypr/hyprpaper.conf > /home/amit/.config/hypr/logs/hyprpaper_debug.log 2>&1 & disown

# Give hyprpaper a moment to start
sleep 0.5

# Force load via IPC in case config fails
hyprctl hyprpaper preload "/home/amit/.config/hypr/wallpapers/prime2.png"
hyprctl hyprpaper wallpaper "eDP-1,/home/amit/.config/hypr/wallpapers/prime2.png"
hyprctl hyprpaper wallpaper ",/home/amit/.config/hypr/wallpapers/prime2.png"
echo "Wallpaper applied instantly."
date >> "/home/amit/.config/hypr/logs/wallpaper_script.log"
