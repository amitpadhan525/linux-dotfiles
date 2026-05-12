#!/bin/bash
# Auto-detect CPU temperature — works across reboots (hwmon number changes)
# Supports AMD (k10temp / zenpower) and Intel (coretemp)

for f in /sys/class/hwmon/hwmon*/name; do
    name=$(cat "$f" 2>/dev/null)
    if [[ "$name" == "k10temp" || "$name" == "zenpower" || "$name" == "coretemp" ]]; then
        dir=$(dirname "$f")
        # k10temp: prefer temp2_input (Tdie, actual die) over temp1_input (Tctl, offset)
        for temp_file in "$dir/temp2_input" "$dir/temp1_input"; do
            [[ -f "$temp_file" ]] || continue
            raw=$(cat "$temp_file" 2>/dev/null)
            [[ -n "$raw" ]] || continue
            celsius=$((raw / 1000))

            if (( celsius >= 80 )); then
                icon=""; color="#f38ba8"
            elif (( celsius >= 55 )); then
                icon=""; color="#f9e2af"
            else
                icon=""; color="#a6e3a1"
            fi

            tooltip="<span color='#cba6f7'>${icon} CPU Temp: </span><span color='${color}'>${celsius}°C</span>"
            printf '{"text":"%s %s°C","tooltip":"%s"}\n' \
                "$icon" "$celsius" \
                "$(printf '%s' "$tooltip" | sed 's/"/\\"/g')"
            exit 0
        done
    fi
done

printf '{"text":"N/A","tooltip":"No CPU temp sensor found"}\n'
