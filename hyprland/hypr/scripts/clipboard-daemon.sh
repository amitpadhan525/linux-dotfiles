#!/usr/bin/env bash

# Prevent multiple duplicate watchers
if pgrep -f "cliphist store" > /dev/null; then
    exit 0
fi

# Watch standard clipboard (Ctrl+C / Copy) for text and images
wl-paste --type text --watch cliphist store &
wl-paste --type image --watch cliphist store &

# Watch primary selection (text selected/highlighted with mouse)
wl-paste --primary --type text --watch cliphist store &
