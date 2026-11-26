#!/usr/bin/env bash

# Prevent multiple duplicate watchers
if pgrep -f "cliphist store" > /dev/null; then
    exit 0
fi

# Watch standard clipboard (Ctrl+C / Copy) for text only (avoids storing large PNGs in cliphist db)
wl-paste --type text --watch cliphist store &

# Primary selection (mouse selection) watching disabled to prevent clipboard history pollution
# wl-paste --primary --type text --watch cliphist store &
