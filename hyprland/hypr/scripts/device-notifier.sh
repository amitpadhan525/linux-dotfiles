#!/usr/bin/env bash

# Acquire lockfile to prevent duplicate instances
exec 9>/tmp/device-notifier-bash.lock
flock -n 9 || exit 0

# Redirect stdout and stderr to a log file for troubleshooting (capped to prevent growth)
log_path="$HOME/.config/hypr/logs/device-notifier.log"
mkdir -p "$(dirname "$log_path")"
[ -f "$log_path" ] && [ "$(wc -l < "$log_path" 2>/dev/null || echo 0)" -gt 300 ] && tail -n 100 "$log_path" > "$log_path.tmp" && mv "$log_path.tmp" "$log_path"
exec >> "$log_path" 2>&1

echo "[$(date +'%Y-%m-%d %H:%M:%S')] device-notifier started."

# Function to send notifications
notify() {
    local title="$1"
    local message="$2"
    local icon="$3"
    notify-send -a "System Monitor" -i "$icon" "$title" "$message"
}

# Find the AC supply path
find_ac_supply() {
    for supply in /sys/class/power_supply/*; do
        if [[ "$supply" == *AC* || "$supply" == *ADP* || "${supply,,}" == *charger* ]]; then
            echo "$(basename "$supply")"
            return 0
        fi
    done
    echo ""
}

AC_NAME=$(find_ac_supply)
LAST_POWER_ONLINE=""

# Get initial power state
if [ -n "$AC_NAME" ] && [ -f "/sys/class/power_supply/$AC_NAME/online" ]; then
    LAST_POWER_ONLINE=$(cat "/sys/class/power_supply/$AC_NAME/online")
fi

# Run udevadm monitor and pipe to a read loop
udevadm monitor --udev --property --subsystem-match=usb --subsystem-match=power_supply | while read -r line; do
    # Clear properties on new event block
    if [[ "$line" == "UDEV "* || -z "$line" ]]; then
        # Handle the event if we have collected properties
        if [ -n "$subsystem" ]; then
            if [ "$subsystem" = "usb" ] && [ "$devtype" = "usb_device" ] && [[ "$action" == "add" || "$action" == "remove" ]]; then
                # Determine device name
                name="${vendor_db:-$vendor} ${model_db:-$model}"
                name=$(echo "$name" | xargs) # trim whitespace
                if [ -z "$name" ]; then
                    name="Unknown USB Device"
                fi

                if [ "$action" = "add" ]; then
                    notify "USB Device Connected" "$name" "drive-removable-media"
                else
                    notify "USB Device Disconnected" "$name" "drive-removable-media"
                fi
            elif [ "$subsystem" = "power_supply" ] && [[ "$supply_name" == "$AC_NAME" || "$supply_name" == *AC* || "$supply_name" == *ADP* ]]; then
                if [ -n "$online" ] && [ "$online" != "$LAST_POWER_ONLINE" ]; then
                    LAST_POWER_ONLINE="$online"
                    if [ "$online" = "1" ]; then
                        notify "Charger Connected" "AC adapter plugged in" "ac-adapter"
                    else
                        notify "Charger Disconnected" "Running on battery power" "battery"
                    fi
                fi
            fi
        fi
        
        # Reset variables for next event
        subsystem=""
        action=""
        devtype=""
        vendor=""
        vendor_db=""
        model=""
        model_db=""
        supply_name=""
        online=""
        continue
    fi

    # Parse key-value pairs
    if [[ "$line" == *=* ]]; then
        key="${line%%=*}"
        val="${line#*=}"
        case "$key" in
            SUBSYSTEM) subsystem="$val" ;;
            ACTION) action="$val" ;;
            DEVTYPE) devtype="$val" ;;
            ID_VENDOR) vendor="$val" ;;
            ID_VENDOR_FROM_DATABASE) vendor_db="$val" ;;
            ID_MODEL) model="$val" ;;
            ID_MODEL_FROM_DATABASE) model_db="$val" ;;
            POWER_SUPPLY_NAME) supply_name="$val" ;;
            POWER_SUPPLY_ONLINE) online="$val" ;;
        esac
    fi
done
