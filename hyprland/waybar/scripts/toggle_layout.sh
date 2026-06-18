#!/usr/bin/env bash

# Ignore signals to prevent being killed when parent waybar is terminated
trap "" SIGHUP SIGTERM SIGINT

CONFIG_DIR="/home/amit/.config/waybar"
STATE_FILE="/tmp/waybar_layout"
CURRENT_LAYOUT=$(cat "$STATE_FILE" 2>/dev/null || echo "daily")

if [ "$CURRENT_LAYOUT" = "system" ]; then
    # Switch to daily layout
    echo "daily" > "$STATE_FILE"
    ln -sf "$CONFIG_DIR/config.daily" "$CONFIG_DIR/config"
else
    # Switch to system layout
    echo "system" > "$STATE_FILE"
    ln -sf "$CONFIG_DIR/config.system" "$CONFIG_DIR/config"
fi

# Reload Waybar configuration instantly if running, otherwise start it
if pgrep -x waybar >/dev/null; then
    pkill -USR2 -x waybar
else
    trap - SIGHUP SIGTERM SIGINT
    sh -c "waybar -c '$CONFIG_DIR/config' -s '$CONFIG_DIR/style.css' >/tmp/waybar_startup.log 2>&1" &
fi
