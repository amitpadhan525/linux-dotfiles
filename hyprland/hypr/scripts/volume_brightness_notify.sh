#!/usr/bin/env bash

# Notification OSD for Volume and Brightness
action="$1"

case "$action" in
    volume_up)
        pamixer -i 5
        ;;
    volume_down)
        pamixer -d 5
        ;;
    volume_mute)
        pamixer -t
        ;;
    brightness_up)
        brightnessctl set +5%
        ;;
    brightness_down)
        brightnessctl set 5%-
        ;;
esac

if [[ "$action" == volume_* ]]; then
    vol=$(pamixer --get-volume 2>/dev/null || echo "0")
    mute=$(pamixer --get-mute 2>/dev/null || echo "false")

    if [ "$mute" = "true" ]; then
        icon="audio-volume-muted-symbolic"
        text="Muted"
        val=0
    else
        val=$vol
        if [ "$vol" -eq 0 ]; then
            icon="audio-volume-muted-symbolic"
        elif [ "$vol" -lt 30 ]; then
            icon="audio-volume-low-symbolic"
        elif [ "$vol" -lt 70 ]; then
            icon="audio-volume-medium-symbolic"
        else
            icon="audio-volume-high-symbolic"
        fi
        text="${vol}%"
    fi
    dunstify -h string:x-dunst-stack-tag:volume -h int:value:"$val" -i "$icon" "Volume: $text" -u low -t 1500

elif [[ "$action" == brightness_* ]]; then
    bright_str=$(brightnessctl -m 2>/dev/null | cut -d, -f4 | tr -d '%')
    val=${bright_str:-0}

    if [ "$val" -lt 30 ]; then
        icon="display-brightness-low-symbolic"
    elif [ "$val" -lt 70 ]; then
        icon="display-brightness-medium-symbolic"
    else
        icon="display-brightness-high-symbolic"
    fi

    dunstify -h string:x-dunst-stack-tag:brightness -h int:value:"$val" -i "$icon" "Brightness: ${val}%" -u low -t 1500
fi
