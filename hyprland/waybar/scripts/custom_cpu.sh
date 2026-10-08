#!/bin/bash

ICO_CPU=""

# /proc/stat diff — accurate real-time CPU %
read_cpu() { awk '/^cpu / {print $2,$3,$4,$5,$6,$7,$8}' /proc/stat; }
snap1=$(read_cpu); sleep 0.05; snap2=$(read_cpu)

cpu_usage=$(awk -v s1="$snap1" -v s2="$snap2" 'BEGIN {
    split(s1,a); split(s2,b)
    idle1=a[4]; total1=0; for(i=1;i<=7;i++) total1+=a[i]
    idle2=b[4]; total2=0; for(i=1;i<=7;i++) total2+=b[i]
    dt=total2-total1; di=idle2-idle1
    print (dt>0) ? int((dt-di)*100/dt) : 0
}')

# CPU Warning Color
if (( cpu_usage >= 80 )); then
    cpu_color="#f87171"
    cpu_class="hot"
else
    cpu_color="#00ffb3"
    cpu_class="normal"
fi

# Find AMD GPU device path
gpu_dev=""
for p in /sys/class/drm/card?/device/gpu_busy_percent; do
    if [ -f "$p" ]; then
        gpu_dev=$(dirname "$p")
        break
    fi
done

gpu_info=""
if [ -n "$gpu_dev" ]; then
    # GPU Busy %
    gpu_busy=$(cat "$gpu_dev/gpu_busy_percent" 2>/dev/null)
    [[ -z "$gpu_busy" ]] && gpu_busy=0
    
    # VRAM
    vram_u=$(cat "$gpu_dev/mem_info_vram_used" 2>/dev/null)
    vram_t=$(cat "$gpu_dev/mem_info_vram_total" 2>/dev/null)
    if [[ -n "$vram_u" && -n "$vram_t" ]]; then
        gpu_vram_u=$((vram_u / 1024 / 1024))
        gpu_vram_t=$((vram_t / 1024 / 1024))
    else
        gpu_vram_u=0; gpu_vram_t=0
    fi
    
    # GPU Warning Color
    if (( gpu_busy >= 80 )); then
        gpu_color="#f87171"
    else
        gpu_color="#00ffb3"
    fi
        
    # GPU Info String
    gpu_info=", <span color='#eba0ac'>GPU:</span> <span color='${gpu_color}'>${gpu_busy}%</span>, <span color='#eba0ac'>VRAM:</span> <span color='#89b4fa'>${gpu_vram_u}/${gpu_vram_t} MB</span>"
fi

tooltip="<span color='#eba0ac'>CPU:</span> <span color='${cpu_color}'>${cpu_usage}%</span>${gpu_info}"

printf '{"text":"%s%%","class":"%s","tooltip":"%s"}\n' \
    "$cpu_usage" "$cpu_class" \
    "$(printf '%b' "$tooltip" | sed 's/"/\\"/g' | awk '{printf "%s\\n",$0}' | tr -d '\n' | sed 's/\\n$//')"
