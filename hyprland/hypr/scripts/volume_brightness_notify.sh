#!/usr/bin/env bash

# Notification OSD for Volume and Brightness
action="$1"

# Load dynamic theme colors if available
COLORS_FILE="$HOME/.config/hypr/colors.sh"
if [ -f "$COLORS_FILE" ]; then
    # shellcheck source=/dev/null
    source "$COLORS_FILE"
fi

ACCENT_COLOR="${accent:-#34d399}"
EMPTY_COLOR="${secondary_text:-#1e4438}"
FAIL_COLOR="${fail_color:-#f87171}"

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
    mic_mute)
        pamixer --default-source -t
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

    echo "<span foreground=\"$ACCENT_COLOR\">$filled_bar</span><span foreground=\"$EMPTY_COLOR\">$empty_bar</span>"
}

if [[ "$action" == volume_* ]]; then
    vol=$(pamixer --get-volume 2>/dev/null || echo "0")
    mute=$(pamixer --get-mute 2>/dev/null || echo "false")

    if [ "$mute" = "true" ]; then
        icon="󰝟"
        title="$icon  Sound: Muted"
        bar="<span foreground=\"$FAIL_COLOR\">━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</span>"
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

elif [[ "$action" == "mic_mute" ]]; then
    mute=$(pamixer --default-source --get-mute 2>/dev/null || echo "false")
    if [ "$mute" = "true" ]; then
        title="  Microphone: Muted"
        bar="<span foreground=\"$FAIL_COLOR\">━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</span>"
    else
        title="  Microphone: Unmuted"
        bar="<span foreground=\"$ACCENT_COLOR\">━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━</span>"
    fi

    notify-send -a "OSD" -h string:x-canonical-private-synchronous:mic -h string:x-dunst-stack-tag:mic -t 2500 "$title" "$bar"
fi
