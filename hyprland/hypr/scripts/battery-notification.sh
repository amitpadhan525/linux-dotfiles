#!/usr/bin/env bash

# Acquire lockfile to prevent duplicate instances
exec 9>/tmp/battery-notification.lock
flock -n 9 || exit 0

# Redirect stdout and stderr to a log file (capped to prevent growth)
log_file="$HOME/.config/hypr/logs/battery-notification.log"
mkdir -p "$(dirname "$log_file")"
[ -f "$log_file" ] && [ "$(wc -l < "$log_file" 2>/dev/null || echo 0)" -gt 300 ] && tail -n 100 "$log_file" > "$log_file.tmp" && mv "$log_file.tmp" "$log_file"
exec >> "$log_file" 2>&1
echo "[$(date +'%Y-%m-%d %H:%M:%S')] battery-notification started."


# Path to the battery info
BAT_PATH="/sys/class/power_supply/BAT0"

# State flags to prevent duplicate notification spam
notified_low=false
notified_full=false

# Infinite monitoring loop
while true; do
    if [ -d "$BAT_PATH" ]; then
        capacity=$(cat "$BAT_PATH/capacity")
        status=$(cat "$BAT_PATH/status")

        # 1. Battery Low Alert (below 20% and discharging)
        if [ "$capacity" -lt 20 ] && [ "$status" = "Discharging" ]; then
            if [ "$notified_low" = false ]; then
                notify-send "Battery Low" "Battery level is at ${capacity}%. Please connect the charger." -u critical -i battery-caution
                notified_low=true
            fi
        # Reset low alert state when plugged in or charged up
        elif [ "$capacity" -ge 20 ] || [ "$status" = "Charging" ]; then
            notified_low=false
        fi

        # 2. Battery Full Alert (100% and plugged in/full)
        if { [ "$capacity" -eq 100 ] || [ "$status" = "Full" ]; } && [ "$status" != "Discharging" ]; then
            if [ "$notified_full" = false ]; then
                notify-send "Battery Fully Charged" "Battery is at 100%. You can unplug the charger." -u normal -i battery-full
                notified_full=true
            fi
        # Reset full alert state when unplugged/discharging
        elif [ "$capacity" -lt 100 ] && [ "$status" = "Discharging" ]; then
            notified_full=false
        fi
    fi
    sleep 30
done
