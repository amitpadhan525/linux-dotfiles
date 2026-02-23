#!/bin/bash
STATE_FILE="$HOME/.config/waybar/scripts/.night_mode_state"

if [ ! -f "$STATE_FILE" ]; then
    echo "OFF" > "$STATE_FILE"
fi

CURRENT_STATE=$(cat "$STATE_FILE")
toggle() {
    if [ "$CURRENT_STATE" = "OFF" ]; then
        if command -v hyprshade &> /dev/null; then
            hyprshade on blue-light-filter
        elif command -v gammastep &> /dev/null; then
            gammastep -O 4500 -P &
            echo $! > /tmp/gammastep_pid
        fi
        echo "ON" > "$STATE_FILE"
        echo '{"text": "", "tooltip": "Night Mode: ON", "class": "active"}'
    else
        if command -v hyprshade &> /dev/null; then
            hyprshade off
        elif command -v gammastep &> /dev/null; then
            pkill gammastep
        fi
        echo "OFF" > "$STATE_FILE"
        echo '{"text": "", "tooltip": "Night Mode: OFF", "class": "inactive"}'
    fi
}
status() {
    if [ "$CURRENT_STATE" = "ON" ]; then
        echo '{"text": "", "tooltip": "Night Mode: ON", "class": "active"}'
    else
        echo '{"text": "", "tooltip": "Night Mode: OFF", "class": "inactive"}'
    fi
}
case "$1" in
    "toggle")
        toggle
        ;;
    *)
        status
        ;;
esac
