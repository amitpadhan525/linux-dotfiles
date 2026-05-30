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
                icon=""; color="#ffb86c" temp_class="hot"
            elif (( celsius >= 55 )); then
                icon=""; color="#8be9fd" temp_class="warm"
            else
                icon=""; color="#50fa7b" temp_class="cool"
            fi

            tooltip="<span color='#89b4fa'>${icon} CPU Temp: </span><span color='${color}'>${celsius}°C</span>"
            printf '{"text":"%s %s°C","class":"%s","tooltip":"%s"}\n' \
                "$icon" "$celsius" "$temp_class" \
                "$(printf '%s' "$tooltip" | sed 's/"/\\"/g')"
            exit 0
        done
    fi
done

printf '{"text":"N/A","tooltip":"No CPU temp sensor found"}\n'
