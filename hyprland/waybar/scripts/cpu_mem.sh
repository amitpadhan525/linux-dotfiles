#!/bin/bash

# ----------------------------------------------------- 
# CPU & Memory Usage Script
# ----------------------------------------------------- 

# Calculate CPU load using /proc/stat
# Formula: (1 - (idle / total)) * 100
cpu=$(awk -v RS="" '/^cpu /{   if the first method fails
if [ -z "$cpu" ] || [ "$cpu" = "n/a" ]; then
  cpu=$(top -b -n2 -d0.2 | awk '/Cpu/ {print $2; exit}' 2>/dev/null || echo "n/a")
fi

# Calculate Memory Usage using free command
mem=$(free -m | awk '/Mem:/ {printf("%d", $3*100/$2)}' 2>/dev/null || echo "n/a")

# Output: CPU% · RAM%
printf "CPU %s%% · RAM %s%%\n" "${cpu:-?}" "${mem:-?}"
