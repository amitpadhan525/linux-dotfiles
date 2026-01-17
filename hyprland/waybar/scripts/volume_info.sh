#!/usr/bin/env bash
# prints: " 42%" or "muted"
# tries pamixer, then pactl
if command -v pamixer >/dev/null 2>&1; then
  vol=$(pamixer --get-volume 2>/dev/null)
  muted=$(pamixer --get-mute 2>/dev/null)
  if [ "$muted" = "true" ]; then
    echo "muted"
  else
    printf " %s%%\n" "${vol:-?}"
  fi
  exit 0
fi
if command -v pactl >/dev/null 2>&1; then
  sink=$(pactl info 2>/dev/null | awk -F': ' '/Default Sink/ {print $2}')
  if [ -n "$sink" ]; then
    vol=$(pactl get-sink-volume "@DEFAULT_SINK@" 2>/dev/null | awk '/Volume:/ {print $5; exit}')
    muted=$(pactl get-sink-mute "@DEFAULT_SINK@" 2>/dev/null | awk '/Mute:/ {print $2; exit}')
    if [ "$muted" = "yes" ]; then
      echo "muted"
    else
      printf " %s\n" "${vol:-?}"
    fi
    exit 0
  fi
fi
echo "audio n/a"
