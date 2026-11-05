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


# Path to the battery info (default BAT0, or first detected battery)
BAT_PATH="/sys/class/power_supply/BAT0"
if [ ! -d "$BAT_PATH" ]; then
    BAT_PATH=$(ls -d /sys/class/power_supply/BAT* 2>/dev/null | head -n1)
fi

# State flags to prevent duplicate notification spam across tiers
notified_low=false
notified_critical=false
notified_emergency=false
notified_full=false

# Infinite monitoring loop
while true; do
    if [ -n "$BAT_PATH" ] && [ -d "$BAT_PATH" ]; then
        capacity=$(cat "$BAT_PATH/capacity" 2>/dev/null || echo "")
        status=$(cat "$BAT_PATH/status" 2>/dev/null || echo "")

        if [[ "$capacity" =~ ^[0-9]+$ ]]; then
            # 1. Tiered Low Battery Alerts (when discharging)
            if [ "$status" = "Discharging" ]; then
                if [ "$capacity" -lt 5 ]; then
                    if [ "$notified_emergency" = false ]; then
                        notify-send -u critical -i battery-empty "Battery Dangerously Low" "Battery level is at ${capacity}%! Plug in charger immediately to avoid shutdown."
                        notified_emergency=true
                        notified_critical=true
                        notified_low=true
                    fi
                elif [ "$capacity" -lt 10 ]; then
                    if [ "$notified_critical" = false ]; then
                        notify-send -u critical -i battery-caution "Battery Critical" "Battery level is at ${capacity}%. Please connect the charger now."
                        notified_critical=true
                        notified_low=true
                    fi
                elif [ "$capacity" -lt 20 ]; then
                    if [ "$notified_low" = false ]; then
                        notify-send -u normal -i battery-caution "Battery Low" "Battery level is at ${capacity}%. Consider plugging in your charger."
                        notified_low=true
                    fi
                fi
            # Reset low alert states when charging or charged back up
            elif [ "$status" = "Charging" ] || [ "$status" = "Full" ] || [ "$capacity" -ge 20 ]; then
                notified_low=false
                notified_critical=false
                notified_emergency=false
            fi

            # Partial reset if capacity recovers above intermediate thresholds
            if [ "$capacity" -ge 10 ]; then
                notified_critical=false
            fi
            if [ "$capacity" -ge 5 ]; then
                notified_emergency=false
            fi

            # 2. Battery Full Alert (100% and plugged in/full)
            if { [ "$capacity" -eq 100 ] || [ "$status" = "Full" ]; } && [ "$status" != "Discharging" ]; then
                if [ "$notified_full" = false ]; then
                    notify-send -u normal -i battery-full "Battery Fully Charged" "Battery is at 100%. You can unplug the charger."
                    notified_full=true
                fi
            # Reset full alert state when unplugged/discharging
            elif [ "$capacity" -lt 100 ] || [ "$status" = "Discharging" ]; then
                notified_full=false
            fi
        fi
    fi
    sleep 30
done
