#!/bin/bash

# Icons stored in variables to avoid encoding issues in Pango spans
ICO_RAM="" ; ICO_SWAP="" ; ICO_ZRAM=""

# RAM
mem_info=$(free -m)
total=$(echo "$mem_info" | awk '/Mem:/ {print $2}')
used=$(echo "$mem_info"  | awk '/Mem:/ {print $3}')
percentage=$((used * 100 / total))
used_gb=$(awk "BEGIN {printf \"%.1f\", $used/1024}")
total_gb=$(awk "BEGIN {printf \"%.1f\", $total/1024}")

# Swap & Zram (single call)
swap_info=$(swapon --show --noheadings --bytes 2>/dev/null)
sw_used=$(echo "$swap_info" | awk '$2=="file"      {printf "%.1f", $4/1073741824}')
sw_size=$(echo "$swap_info" | awk '$2=="file"      {printf "%.0f", $3/1073741824}')
zr_used=$(echo "$swap_info" | awk '$2=="partition" {printf "%.1f", $4/1073741824}')
zr_size=$(echo "$swap_info" | awk '$2=="partition" {printf "%.0f", $3/1073741824}')
[[ -z "$sw_used" ]] && sw_used="0.0"; [[ -z "$sw_size" ]] && sw_size="0"
[[ -z "$zr_used" ]] && zr_used="0.0"; [[ -z "$zr_size" ]] && zr_size="0"

# RAM color
ram_color=$(awk -v v="$percentage" 'BEGIN {
    if(v>=80) print "#f38ba8"; else if(v>=50) print "#f9e2af"; else print "#a6e3a1" }')

# Top 10 processes aggregated by name
mapfile -t procs < <(ps axch -o cmd:15,rss | awk '{sum[$1]+=$2; count[$1]++} END {for (p in sum) print (count[p] > 1 ? p"["count[p]"]" : p), sum[p]}' | sort -rn -k2 | head -n 10)

left_lines=(); right_lines=()
for i in "${!procs[@]}"; do
    read -r name rss <<< "${procs[$i]}"
    name=${name//[<>&]/.}
    mb=$(( rss / 1024 ))
    rank=$((i + 1))

    if (( mb >= 500 )); then mb_color="#f38ba8"
    elif (( mb >= 150 )); then mb_color="#f9e2af"
    else mb_color="#a6e3a1"; fi

    if (( mb >= 1000 )); then
        gb10=$(( (mb * 10) / 1024 ))
        mem_str="$((gb10 / 10)).$((gb10 % 10))G"
    else
        mem_str="${mb}M"
    fi

    r=$(printf '%2d' "$rank")
    n=$(printf '%-12.12s' "$name")
    m=$(printf '%5s' "$mem_str")

    entry="<span color='#6c7086'>${r}</span> <span color='#cdd6f4'>${n}</span><span color='${mb_color}'>${m}</span>"
    if (( i < 5 )); then left_lines+=("$entry"); else right_lines+=("$entry"); fi
done

# Compact header & divider
hdr=$(printf '%-2s %-12s%5s' '#' 'PROC' 'MEM')
col_header="<span color='#cba6f7'>${hdr}   ${hdr}</span>"
div=$(printf '%-2s %-12s%5s' '--' '------------' '-----')
col_divider="<span color='#45475a'>${div}   ${div}</span>"

rows=""
for i in {0..4}; do
    rows="${rows}${left_lines[$i]}   ${right_lines[$i]}\n"
done

# Tooltip — icons outside span tags
tooltip="${ICO_RAM} <span color='${ram_color}'>${used_gb}/${total_gb} GiB</span> <span color='#6c7086'>${percentage}%</span>   ${ICO_SWAP} <span color='#94e2d5'>${sw_used}/${sw_size}G</span>  ${ICO_ZRAM} <span color='#89b4fa'>${zr_used}/${zr_size}G</span>\n"
tooltip+=" \n"
tooltip+=" ${col_header}\n ${col_divider}\n${rows}"

printf '{"text":"%s%%","tooltip":"%s"}\n' \
    "$percentage" \
    "$(printf '%b' "$tooltip" | sed 's/"/\\"/g' | awk '{printf "%s\\n",$0}' | tr -d '\n' | sed 's/\\n$//')"
