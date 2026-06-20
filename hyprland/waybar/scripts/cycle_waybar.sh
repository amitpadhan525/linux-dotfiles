#!/usr/bin/env bash

# Reset traps to default behavior so child waybar doesn't inherit ignored signals
trap - SIGHUP SIGTERM SIGINT

# Check if waybar is running at all
if ! pgrep -x waybar >/dev/null; then
    # Toggle on: Start Waybar with primary layout
    nohup waybar -c "$HOME/.config/waybar/config" -s "$HOME/.config/waybar/style.css" >/dev/null 2>&1 &
else
    # Toggle off: Kill waybar
    pkill -x waybar
fi
