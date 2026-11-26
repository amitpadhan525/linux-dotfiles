#!/bin/bash

# Load dynamic theme colors if available
COLORS_FILE="$HOME/.config/hypr/colors.sh"
if [ -f "$COLORS_FILE" ]; then
    # shellcheck source=/dev/null
    source "$COLORS_FILE"
fi
ACCENT_HEX="${accent:-#34d399}"
FAIL_HEX="${fail_color:-#f87171}"

# Zero-sleep /proc/stat delta using cached previous sample
CACHE_FILE="/tmp/waybar_cpu_prev"
read -r _ u n s i io irq sirq _ < /proc/stat
cur_idle=$(( i + io ))
cur_total=$(( u + n + s + i + io + irq + sirq ))

if [ -f "$CACHE_FILE" ]; then
    read -r prev_idle prev_total < "$CACHE_FILE" 2>/dev/null || true
else
    prev_idle="$cur_idle"
    prev_total="$cur_total"
fi
printf '%s %s\n' "$cur_idle" "$cur_total" > "$CACHE_FILE"

dt=$(( cur_total - ${prev_total:-cur_total} ))
di=$(( cur_idle - ${prev_idle:-cur_idle} ))
if [ "$dt" -gt 0 ]; then
    cpu_usage=$(( (dt - di) * 100 / dt ))
else
    cpu_usage=0
fi

# CPU Warning Color
if (( cpu_usage >= 80 )); then
    cpu_color="$FAIL_HEX"
    cpu_class="hot"
else
    cpu_color="$ACCENT_HEX"
    cpu_class="normal"
fi

# Find AMD GPU device path
gpu_dev=""
for p in /sys/class/drm/card?/device/gpu_busy_percent; do
    if [ -f "$p" ]; then
        gpu_dev="${p%/gpu_busy_percent}"
        break
    fi
done

gpu_info=""
if [ -n "$gpu_dev" ]; then
    gpu_busy=$(cat "$gpu_dev/gpu_busy_percent" 2>/dev/null)
    [[ -z "$gpu_busy" ]] && gpu_busy=0

    vram_u=$(cat "$gpu_dev/mem_info_vram_used" 2>/dev/null)
    vram_t=$(cat "$gpu_dev/mem_info_vram_total" 2>/dev/null)
    if [[ -n "$vram_u" && -n "$vram_t" ]]; then
        gpu_vram_u=$((vram_u / 1048576))
        gpu_vram_t=$((vram_t / 1048576))
    else
        gpu_vram_u=0; gpu_vram_t=0
    fi

    if (( gpu_busy >= 80 )); then
        gpu_color="$FAIL_HEX"
    else
        gpu_color="$ACCENT_HEX"
    fi

    gpu_info=", <span color='#eba0ac'>GPU:</span> <span color='${gpu_color}'>${gpu_busy}%</span>, <span color='#eba0ac'>VRAM:</span> <span color='#89b4fa'>${gpu_vram_u}/${gpu_vram_t} MB</span>"
fi

tooltip="<span color='#eba0ac'>CPU:</span> <span color='${cpu_color}'>${cpu_usage}%</span>${gpu_info}"

printf '{"text":"%s%%","class":"%s","tooltip":"%s"}\n' \
    "$cpu_usage" "$cpu_class" "${tooltip//\"/\\\"}"
