#!/usr/bin/env bash

df_out=$(df -h / /home --total 2>/dev/null)
read -r r_used r_size r_pct h_used h_size h_pct t_used t_size t_pct <<< $(echo "$df_out" | awk '
NR==2 { r_u=$3; r_s=$2; r_p=$5 }
NR==3 { h_u=$3; h_s=$2; h_p=$5 }
NR==4 { t_u=$3; t_s=$2; t_p=$5 }
END { print r_u, r_s, r_p, h_u, h_s, h_p, t_u, t_s, t_p }
')

info_root=$(printf "%-14s: %5s / %-5s (%s)" "Root (/)" "$r_used" "$r_size" "$r_pct")
info_home=$(printf "%-14s: %5s / %-5s (%s)" "Home (/home)" "$h_used" "$h_size" "$h_pct")
info_total=$(printf "%-14s: %5s / %-5s (%s)" "Total" "$t_used" "$t_size" "$t_pct")

total_p_num="${t_pct//%/}"
[[ "$total_p_num" =~ ^[0-9]+$ ]] || total_p_num=0

tooltip=$(printf "<b>Disk Usage Information</b>\n\n%s\n%s\n---------------------------------\n%s" \
    "$info_root" \
    "$info_home" \
    "$info_total")

jq -n -c \
  --arg text " $t_pct" \
  --arg tooltip "$tooltip" \
  --argjson percentage "$total_p_num" \
  '{"text": $text, "tooltip": $tooltip, "percentage": $percentage}'
