#!/usr/bin/env bash
# prints: "CPU 12% · RAM 34%"
cpu=$(awk -v RS="" '/^cpu /{sum=0; for(i=2;i<=NF;i++) sum+=$i; idle=$5; total=sum; print (1-(idle/total))*100}' /proc/stat 2>/dev/null | awk '{printf "%.0f\n",$1}' 2>/dev/null || printf "n/a")
# fallback simpler CPU using top
if [ -z "$cpu" ] || [ "$cpu" = "n/a" ]; then
  cpu=$(top -b -n2 -d0.2 | awk '/Cpu/ {print $2; exit}' 2>/dev/null || echo "n/a")
fi
mem=$(free -m | awk '/Mem:/ {printf("%d", $3*100/$2)}' 2>/dev/null || echo "n/a")
printf "CPU %s%% · RAM %s%%\n" "${cpu:-?}" "${mem:-?}"
