#!/bin/bash
# Toggle all windows between tiling and floating
# Saves state in /tmp/hypr_floating_mode

STATE_FILE="/tmp/hypr_floating_mode"

# Get client addresses; exit quietly if none
clients=$(hyprctl clients -j 2>/dev/null | jq -r '.[].address' 2>/dev/null || true)
if [ -z "$clients" ]; then
  # nothing to toggle, still flip state so new windows can be handled manually
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
  # Turn OFF floating: explicitly set floating off for each
  for wid in $clients; do
    hyprctl dispatch setfloating address:$wid off
  done
  rm -f "$STATE_FILE"
  notify-send "🧱 Back to tiling mode"
else
  # Turn ON floating: explicitly set floating on for each
  for wid in $clients; do
    hyprctl dispatch setfloating address:$wid on
  done
  touch "$STATE_FILE"
  notify-send "🪟 Floating mode enabled"
fi
