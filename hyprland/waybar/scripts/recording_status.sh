#!/usr/bin/env bash
# Lightweight recording status output for Waybar (avoids spawning Python every second)

PID_FILE="/tmp/wf-recorder.pid"

if [ ! -f "$PID_FILE" ]; then
    printf '{"text":"","class":"hidden"}\n'
    exit 0
fi

PID=$(tr -d '[:space:]' < "$PID_FILE" 2>/dev/null)
if [ -z "$PID" ] || ! kill -0 "$PID" 2>/dev/null; then
    printf '{"text":"","class":"hidden"}\n'
    exit 0
fi

MTIME=$(stat -c %Y "$PID_FILE" 2>/dev/null || echo 0)
NOW=$(date +%s)
ELAPSED=$(( NOW - MTIME ))
[ "$ELAPSED" -lt 0 ] && ELAPSED=0

MINS=$(( ELAPSED / 60 ))
SECS=$(( ELAPSED % 60 ))
TIME_STR=$(printf '%02d:%02d' "$MINS" "$SECS")

if [ $(( ELAPSED % 2 )) -eq 0 ]; then
    DOT="●"
else
    DOT=" "
fi

printf '{"text":"%s  REC  %s","class":"recording","tooltip":"Recording active for %s. Click to Stop."}\n' \
    "$DOT" "$TIME_STR" "$TIME_STR"
