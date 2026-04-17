#!/usr/bin/env bash

df_out=$(df -h / 2>/dev/null)
read -r r_used r_size r_pct <<< $(echo "$df_out" | awk 'NR==2 { print $3, $2, $5 }')

info_root=$(printf "%-14s: %5s / %-5s (%s)" "Disk (/)" "$r_used" "$r_size" "$r_pct")

total_p_num="${r_pct//%/}"
[[ "$total_p_num" =~ ^[0-9]+$ ]] || total_p_num=0

tooltip=$(printf "<b>Disk Usage Information</b>\n\n%s" "$info_root")

jq -n -c \
  --arg text " $r_pct" \
  --arg tooltip "$tooltip" \
  --argjson percentage "$total_p_num" \
  '{"text": $text, "tooltip": $tooltip, "percentage": $percentage}'
