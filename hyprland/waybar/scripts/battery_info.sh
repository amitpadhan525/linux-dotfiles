#!/usr/bin/env bash
# prints " 86%" or " 100% (charging)"
# try upower, then acpi
if command -v upower >/dev/null 2>&1; then
  # choose first battery device
  dev=$(upower -e | grep -i battery | head -n1)
  if [ -n "$dev" ]; then
    info=$(upower -i "$dev")
    cap=$(echo "$info" | awk '/percentage:/ {print $2}' | tr -d '%')
    state=$(echo "$info" | awk '/state:/ {print $2}')
    if [ "$state" = "charging" ]; then
      printf " %s%%\n" "$cap"
    else
      printf " %s%%\n" "$cap"
    fi
    exit 0
  fi
fi
if command -v acpi >/dev/null 2>&1; then
  out=$(acpi -b 2>/dev/null)
  if [ -n "$out" ]; then
    # e.g. Battery 0: Discharging, 86%, 03:12:59 remaining
    cap=$(echo "$out" | awk -F', ' '{print $2}' | tr -d '%')
    state=$(echo "$out" | awk -F': ' '{print $2}' | awk -F', ' '{print $1}')
    if echo "$state" | grep -iq charging; then
      printf " %s%%\n" "$cap"
    else
      printf " %s%%\n" "$cap"
    fi
    exit 0
  fi
fi
echo "battery n/a"
