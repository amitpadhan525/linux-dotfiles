#!/bin/bash

apps=(
  "firefox:"
  "kitty:"
  "thunar:"
  "code:󰨞"
)

json="{\"text\":\"\",\"class\":\"dock\"}"

for app in "${apps[@]}"; do
  name="${app%%:*}"
  icon="${app##*:}"
  json=$(echo "$json" | jq ".text += \"<span clickable=\\\"true\\\" onclick=\\\"hyprctl dispatch exec $name\\\"> $icon </span>\"")
done

echo "$json"
