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
        brightnessctl -q set +5%
        ;;
    brightness_down)
        brightnessctl -q set 5%-
        ;;
esac

generate_bar() {
    local val="${1:-0}"
    local total=32
    local filled=$(( (val * total + 50) / 100 ))
    [ "$filled" -gt "$total" ] && filled="$total"
    [ "$filled" -lt 0 ] && filled=0
    local empty=$(( total - filled ))

    local filled_bar=""
    for ((i=0; i<filled; i++)); do filled_bar+="━"; done

    local empty_bar=""
    for ((i=0; i<empty; i++)); do empty_bar+="━"; done

    echo "<span foreground=\"#34d399\">$filled_bar</span><span foreground=\"#1e4438\">$empty_bar</span>"
}

if [[ "$action" == volume_* ]]; then
    vol=$(pamixer --get-volume 2>/dev/null || echo "0")
    mute=$(pamixer --get-mute 2>/dev/null || echo "false")

    if [ "$mute" = "true" ]; then
        icon="󰝟"
        title="$icon  Sound: Muted"
        bar="<span foreground=\"#f87171\">━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</span>"
    else
        if [ "$vol" -eq 0 ]; then
            icon="󰝟"
        elif [ "$vol" -lt 30 ]; then
            icon="󰕿"
        elif [ "$vol" -lt 70 ]; then
            icon="󰖀"
        else
            icon="󰕾"
        fi
        title="$icon  Sound: ${vol}%"
        bar=$(generate_bar "$vol")
    fi

    notify-send -a "OSD" -h string:x-canonical-private-synchronous:volume -h string:x-dunst-stack-tag:volume -t 2500 "$title" "$bar"

elif [[ "$action" == brightness_* ]]; then
    bright_str=$(brightnessctl -m 2>/dev/null | cut -d, -f4 | tr -d '%')
    val=${bright_str:-0}

    if [ "$val" -lt 30 ]; then
        icon="󰃞"
    elif [ "$val" -lt 70 ]; then
        icon="󰃟"
    else
        icon="󰃠"
    fi
    title="$icon  Brightness: ${val}%"
    bar=$(generate_bar "$val")

    notify-send -a "OSD" -h string:x-canonical-private-synchronous:brightness -h string:x-dunst-stack-tag:brightness -t 2500 "$title" "$bar"
fi
