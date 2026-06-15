#!/usr/bin/env bash

# Find battery directory
BAT_DIR=""
for bat in /sys/class/power_supply/BAT* /sys/class/power_supply/bat*; do
    if [ -d "$bat" ]; then
        BAT_DIR="$bat"
        break
    fi
done

if [ -z "$BAT_DIR" ]; then
    echo "No Battery"
    exit 0
fi

capacity=$(cat "$BAT_DIR/capacity" 2>/dev/null || echo 0)
status=$(cat "$BAT_DIR/status" 2>/dev/null || echo "Unknown")

# Select Nerd Font icon based on status and capacity
if [[ "$status" == *"Charging"* ]]; then
    icon="󱐋"
else
    if [ "$capacity" -ge 95 ]; then
        icon="󰁹"
    elif [ "$capacity" -ge 90 ]; then
        icon="󰂂"
    elif [ "$capacity" -ge 80 ]; then
        icon="󰂁"
    elif [ "$capacity" -ge 70 ]; then
        icon="󰂀"
    elif [ "$capacity" -ge 60 ]; then
        icon="󰁿"
    elif [ "$capacity" -ge 50 ]; then
        icon="󰁾"
    elif [ "$capacity" -ge 40 ]; then
        icon="󰁽"
    elif [ "$capacity" -ge 30 ]; then
        icon="󰁼"
    elif [ "$capacity" -ge 20 ]; then
        icon="󰁻"
    elif [ "$capacity" -ge 10 ]; then
        icon="󰁺"
    else
        icon="󰂎"
    fi
fi

echo -n "$icon $capacity%"
