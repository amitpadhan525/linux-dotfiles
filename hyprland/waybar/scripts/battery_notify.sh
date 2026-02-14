#!/bin/bash

# Battery Notification Script
# Intended to be run by Waybar module or background process

BATTERY="BAT0"
BAT_PATH="/sys/class/power_supply/$BATTERY"

# Find battery if BAT0 not found
if [ ! -d "$BAT_PATH" ]; then
    BAT_PATH=$(find /sys/class/power_supply -name "BAT*" | head -n1)
fi

if [ -z "$BAT_PATH" ]; then
    exit 0
fi

CAPACITY=$(cat "$BAT_PATH/capacity")
STATUS=$(cat "$BAT_PATH/status")

# Temp files to store notification state
LOCK_FILE_20="/tmp/waybar_battery_notify_20"
LOCK_FILE_10="/tmp/waybar_battery_notify_10"

if [ "$STATUS" = "Discharging" ]; then
    if [ "$CAPACITY" -le 10 ]; then
        if [ ! -f "$LOCK_FILE_10" ]; then
            notify-send -u critical "Battery Critical" "Battery is at ${CAPACITY}% - Plug in now!"
            touch "$LOCK_FILE_10"
            touch "$LOCK_FILE_20" # Also silence 20% warning
        fi
    elif [ "$CAPACITY" -le 20 ]; then
        if [ ! -f "$LOCK_FILE_20" ]; then
            notify-send -u critical "Battery Low" "Battery is at ${CAPACITY}%"
            touch "$LOCK_FILE_20"
        fi
    fi
else
    # Charging: clear flags
    if [ -f "$LOCK_FILE_20" ]; then rm "$LOCK_FILE_20"; fi
    if [ -f "$LOCK_FILE_10" ]; then rm "$LOCK_FILE_10"; fi
fi
