#!/bin/bash

# RAM usage from free
mem_info=$(free -m)
total=$(echo "$mem_info" | awk '/Mem:/ {print $2}')
used=$(echo "$mem_info" | awk '/Mem:/ {print $3}')
percentage=$((used * 100 / total))

used_gb=$(awk "BEGIN {printf \"%.1f\", $used/1024}")
total_gb=$(awk "BEGIN {printf \"%.1f\", $total/1024}")

# Top 5 RAM processes by actual RSS in MB
top5=$(ps axch -o cmd:15,rss --sort=-rss | head -n 5 | awk '{printf "%-15s %4.0f MB\n", $1, $2/1024}')

# Escape newlines for JSON
tooltip="RAM: ${used_gb}GiB / ${total_gb}GiB\n\nTop 5 RAM Processes:\n${top5}"

printf '{"text":"%s%%","tooltip":"%s"}\n' "$percentage" "$(echo "$tooltip" | sed 's/"/\\"/g' | awk '{printf "%s\\n",$0}' | tr -d '\n' | sed 's/\\n$//')"
