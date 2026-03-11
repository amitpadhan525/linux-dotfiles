#!/bin/bash

# Find AMD GPU device path
dev_path=""
for p in /sys/class/drm/card?/device/gpu_busy_percent; do
    if [ -f "$p" ]; then
        dev_path=$(dirname "$p")
        break
    fi
done

if [ -z "$dev_path" ]; then
    printf '{"text":"N/A","tooltip":"No AMD GPU found"}\n'
    exit 0
fi

# GPU Busy %
busy=$(cat "$dev_path/gpu_busy_percent" 2>/dev/null)
[[ -z "$busy" ]] && busy=0

# VRAM
vram_u=$(cat "$dev_path/mem_info_vram_used" 2>/dev/null)
vram_t=$(cat "$dev_path/mem_info_vram_total" 2>/dev/null)

if [[ -n "$vram_u" && -n "$vram_t" ]]; then
    u_mb=$((vram_u / 1024 / 1024))
    t_mb=$((vram_t / 1024 / 1024))
else
    u_mb=0; t_mb=0
fi

# Temperature
temp_str="N/A"
hwmon_temp=$(find "$dev_path/hwmon" -name "temp1_input" 2>/dev/null | head -n1)
if [[ -n "$hwmon_temp" && -f "$hwmon_temp" ]]; then
    temp_millic=$(cat "$hwmon_temp" 2>/dev/null)
    [[ -n "$temp_millic" ]] && temp_str="$((temp_millic / 1000))°C"
fi

# Colors
gpu_color=$(awk -v v="$busy" 'BEGIN {
    if(v+0>=70) print "#f38ba8"; else if(v+0>=30) print "#f9e2af"; else print "#a6e3a1" }')

vram_pct=0
[[ $t_mb -gt 0 ]] && vram_pct=$(( u_mb * 100 / t_mb ))

vram_color=$(awk -v v="$vram_pct" 'BEGIN {
    if(v+0>=80) print "#f38ba8"; else if(v+0>=50) print "#f9e2af"; else print "#a6e3a1" }')

# Build tooltip
tooltip="<span color='#cba6f7'>󰢮 iGPU: </span><span color='${gpu_color}'>${busy}%</span>   <span color='#89b4fa'>󰘚 VRAM: </span><span color='${vram_color}'>${u_mb}/${t_mb} MB</span>"
if [[ "$temp_str" != "N/A" ]]; then
    tooltip+="   <span color='#f38ba8'> Temp: </span><span color='#cdd6f4'>${temp_str}</span>"
fi

printf '{"text":"%s%%","tooltip":"%s"}\n' \
    "$busy" \
    "$(printf '%b' "$tooltip" | sed 's/"/\\"/g' | awk '{printf "%s\\n",$0}' | tr -d '\n' | sed 's/\\n$//')"
