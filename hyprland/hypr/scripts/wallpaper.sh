#!/bin/bash
# ----------------------------------------------------- 
# Dual Wallpaper launcher (Desktop & Hyprlock) - Portable Dotfiles
# ----------------------------------------------------- 

DEFAULT_DESKTOP="\$HOME/.config/hypr/wallpapers/desktop_wallpaper.png"
DEFAULT_LOCKSCREEN="\$HOME/.config/hypr/wallpapers/lockscreen_wallpaper.jpg"

STATE_DESKTOP="$HOME/.config/hypr/.current_wallpaper"
STATE_LOCKSCREEN="$HOME/.config/hypr/.current_lockscreen"

CONF="$HOME/.config/hypr/hyprpaper.conf"
LOG="$HOME/.config/hypr/logs/hyprpaper.log"

exec > "$LOG" 2>&1
echo "--- Wallpaper launcher started: $(date) ---"

save_portable_path() {
    local raw_path="$1"
    local target_file="$2"
    local abs_path
    abs_path=$(realpath "$raw_path")
    local portable_path="${abs_path/#$HOME/\$HOME}"
    echo "$portable_path" > "$target_file"
}

# Handle CLI flags or positional arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --desktop|-d)
            if [ -f "$2" ]; then save_portable_path "$2" "$STATE_DESKTOP"; shift; fi
            ;;
        --lockscreen|-l)
            if [ -f "$2" ]; then save_portable_path "$2" "$STATE_LOCKSCREEN"; shift; fi
            ;;
        *)
            if [ -z "$POS1" ]; then
                POS1="$1"
            elif [ -z "$POS2" ]; then
                POS2="$1"
            fi
            ;;
    esac
    shift
done

if [ -n "$POS1" ] && [ -f "$POS1" ]; then
    save_portable_path "$POS1" "$STATE_DESKTOP"
fi
if [ -n "$POS2" ] && [ -f "$POS2" ]; then
    save_portable_path "$POS2" "$STATE_LOCKSCREEN"
fi

# 1. Read System Desktop Wallpaper
if [ -f "$STATE_DESKTOP" ]; then
    RAW_DESKTOP=$(cat "$STATE_DESKTOP" | tr -d '\r\n')
    eval DESKTOP_WP="$RAW_DESKTOP"
    if [ ! -f "$DESKTOP_WP" ]; then
        eval DESKTOP_WP="$DEFAULT_DESKTOP"
    fi
else
    eval DESKTOP_WP="$DEFAULT_DESKTOP"
fi

if [ ! -f "$DESKTOP_WP" ]; then
    if [ -f "$HOME/.config/hypr/wallpapers/lockscreen_wallpaper.jpg" ]; then
        cp "$HOME/.config/hypr/wallpapers/lockscreen_wallpaper.jpg" "$HOME/.config/hypr/wallpapers/desktop_wallpaper.png"
    elif [ -f "$HOME/Pictures/background/theme1/wallpaper/wallpaper.jpg" ]; then
        cp "$HOME/Pictures/background/theme1/wallpaper/wallpaper.jpg" "$HOME/.config/hypr/wallpapers/desktop_wallpaper.png"
    fi
    eval DESKTOP_WP="$DEFAULT_DESKTOP"
fi
save_portable_path "$DESKTOP_WP" "$STATE_DESKTOP"

# 2. Read Hyprlock Wallpaper
if [ -f "$STATE_LOCKSCREEN" ]; then
    RAW_LOCK=$(cat "$STATE_LOCKSCREEN" | tr -d '\r\n')
    eval LOCK_WP="$RAW_LOCK"
    if [ ! -f "$LOCK_WP" ]; then
        eval LOCK_WP="$DEFAULT_LOCKSCREEN"
        save_portable_path "$LOCK_WP" "$STATE_LOCKSCREEN"
    fi
else
    eval LOCK_WP="$DEFAULT_LOCKSCREEN"
    save_portable_path "$LOCK_WP" "$STATE_LOCKSCREEN"
fi

echo "Selected Desktop Wallpaper:  $DESKTOP_WP"
echo "Selected Hyprlock Wallpaper: $LOCK_WP"

# 3. Update hyprpaper configuration for Desktop
DESKTOP_WP_PORTABLE="${DESKTOP_WP/#$HOME/\$HOME}"
cat <<EOF > "$CONF"
wallpaper {
    monitor = 
    path = $DESKTOP_WP_PORTABLE
}
splash = false
ipc = on
EOF

# 4. Sync Hyprlock wallpaper file target
if [ -f "$LOCK_WP" ] && [ "$LOCK_WP" != "$HOME/.config/hypr/wallpapers/lockscreen_wallpaper.jpg" ]; then
    cp "$LOCK_WP" "$HOME/.config/hypr/wallpapers/lockscreen_wallpaper.jpg"
fi

# 5. Restart hyprpaper
killall -q hyprpaper
while pgrep -x hyprpaper > /dev/null; do sleep 0.05; done

setsid /usr/bin/hyprpaper -c "$CONF" > "$HOME/.config/hypr/logs/hyprpaper_daemon.log" 2>&1 &

sleep 0.2

if pgrep -x hyprpaper > /dev/null; then
    echo "hyprpaper is running. Done."
else
    echo "ERROR: hyprpaper failed to stay alive."
fi

date >> "$HOME/.config/hypr/logs/wallpaper_script.log"
