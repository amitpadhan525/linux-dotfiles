#!/bin/bash
STATE_FILE="/tmp/hypr_floating_mode"
clients=$(hyprctl clients -j 2>/dev/null | jq -r '.[].address' 2>/dev/null || true)
if [ -z "$clients" ]; then
  if [ -f "$STATE_FILE" ]; then
    rm -f "$STATE_FILE"
    notify-send "🧱 Tiling mode enabled (no windows found)"
  else
    touch "$STATE_FILE"
    notify-send "🪟 Floating mode enabled (no windows found)"
  fi
  exit 0
fi
if [ -f "$STATE_FILE" ]; then
  for wid in $clients; do
    hyprctl dispatch setfloating address:$wid off
  done
  rm -f "$STATE_FILE"
  notify-send "🧱 Back to tiling mode"
else
  for wid in $clients; do
    hyprctl dispatch setfloating address:$wid on
  done
  touch "$STATE_FILE"
  notify-send "🪟 Floating mode enabled"
fi
