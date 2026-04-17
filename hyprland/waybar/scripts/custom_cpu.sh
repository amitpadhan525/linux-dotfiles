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

cpu_color=$(awk -v v="$cpu_usage" 'BEGIN {
    if(v+0>=70) print "#f38ba8"; else if(v+0>=30) print "#f9e2af"; else print "#a6e3a1" }')

tooltip="${ICO_CPU} <span color='#eba0ac'>CPU:</span> <span color='${cpu_color}'>${cpu_usage}%</span>"

printf '{"text":"%s%%","tooltip":"%s"}\n' \
    "$cpu_usage" \
    "$(printf '%b' "$tooltip" | sed 's/"/\\"/g' | awk '{printf "%s\\n",$0}' | tr -d '\n' | sed 's/\\n$//')"
