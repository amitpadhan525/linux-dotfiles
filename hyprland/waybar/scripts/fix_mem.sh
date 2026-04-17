#!/bin/bash
# Top 10 procs
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

for i in {0..4}; do
    echo -e "${left_lines[$i]}   ${right_lines[$i]}"
done
