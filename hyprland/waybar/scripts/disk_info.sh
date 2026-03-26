#!/usr/bin/env bash

# Function to get individual row for a mount point
get_row() {
    local path=$1
    local name=$2
    local stats=$(df -k "$path" 2>/dev/null | tail -n 1)
    
    if [[ -z "$stats" ]]; then
        printf "%-14s: %5s / %-5s (%s)" "$name" "0" "0" "0%"
        return
    fi

    local size=$(df -h "$path" | awk 'NR==2 {print $2}')
    local used=$(df -h "$path" | awk 'NR==2 {print $3}')
    local percent=$(df -h "$path" | awk 'NR==2 {print $5}')
    
    printf "%-14s: %5s / %-5s (%s)" "$name" "$used" "$size" "$percent"
}

# 1. Build individual partition info
info_root=$(get_row / "Root (/)")
info_home=$(get_row /home "Home (/home)")

# 2. Get total stats
total_stats=$(df -h / /home --total 2>/dev/null | grep total)
if [[ -z "$total_stats" ]]; then
    total_size="0"
    total_used="0"
    total_percent="0%"
    total_p_num=0
else
    total_size=$(echo "$total_stats" | awk '{print $2}')
    total_used=$(echo "$total_stats" | awk '{print $3}')
    total_percent=$(echo "$total_stats" | awk '{print $5}')
    total_p_num=$(echo "$total_percent" | tr -d '%')
    # Use 0 if total_p_num is not a number
    [[ "$total_p_num" =~ ^[0-9]+$ ]] || total_p_num=0
fi

info_total=$(printf "%-14s: %5s / %-5s (%s)" "Total" "$total_used" "$total_size" "$total_percent")

# 3. Combine with explicit newlines
tooltip=$(printf "<b>Disk Usage Information</b>\n\n%s\n%s\n---------------------------------\n%s" \
    "$info_root" \
    "$info_home" \
    "$info_total")

# 4. Use jq for safe JSON generation, -c for single line
jq -n -c \
  --arg text " $total_percent" \
  --arg tooltip "$tooltip" \
  --argjson percentage "$total_p_num" \
  '{"text": $text, "tooltip": $tooltip, "percentage": $percentage}'
