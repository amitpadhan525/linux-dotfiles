#!/bin/bash
# ----------------------------------------------------- 
# Wallpaper launcher for hyprpaper v0.8.x (Dynamic)
# ----------------------------------------------------- 

DEFAULT_WALLPAPER="/home/amit/.config/hypr/wallpapers/prime2.png"
STATE_FILE="/home/amit/.config/hypr/.current_wallpaper"
CONF="/home/amit/.config/hypr/hyprpaper.conf"
LOG="/home/amit/.config/hypr/logs/hyprpaper.log"

exec > "$LOG" 2>&1
echo "--- Wallpaper launcher started: $(date) ---"

# 1. Determine active wallpaper path
if [ -n "$1" ]; then
    # Resolve relative paths to absolute paths
    TARGET_WP=$(realpath "$1")
    if [ -f "$TARGET_WP" ]; then
        WALLPAPER="$TARGET_WP"
        echo "$WALLPAPER" > "$STATE_FILE"
    else
        echo "ERROR: File $1 does not exist." >&2
        exit 1
    fi
else
    if [ -f "$STATE_FILE" ]; then
        WALLPAPER=$(cat "$STATE_FILE")
    else
        WALLPAPER="$DEFAULT_WALLPAPER"
    fi
fi

echo "Selected Wallpaper: $WALLPAPER"

# 2. Update hyprpaper configuration dynamically
cat <<EOF > "$CONF"
preload = $WALLPAPER
wallpaper = eDP-1,$WALLPAPER
splash = false
ipc = on
EOF

# 3. Update lockscreen wallpaper to match
cp "$WALLPAPER" "/home/amit/.config/hypr/wallpapers/lockscreen.png"

# 4. Restart hyprpaper
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
