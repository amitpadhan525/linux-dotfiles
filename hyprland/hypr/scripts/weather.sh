#!/usr/bin/env bash

# ----------------------------------------------------- 
# Non-blocking Weather script for hyprlock
# ----------------------------------------------------- 

CACHE_FILE="/tmp/hyprlock_weather.cache"
LOCKED_FILE="/tmp/hyprlock_weather.lock"

# Function to fetch weather
fetch_weather() {
    WEATHER=$(curl -s --connect-timeout 3 "wttr.in/Mumbai?format=%l+%t" | sed 's/+//g')
    if [ -n "$WEATHER" ] && [[ "$WEATHER" != *"Error"* ]]; then
        echo "$WEATHER" > "$CACHE_FILE"
    fi
}

if [ ! -f "$CACHE_FILE" ]; then
    # First run: fetch in foreground to populate cache
    fetch_weather
else
    # Cache exists, check if older than 15 minutes (900 seconds)
    if [ $(( $(date +%s) - $(stat -c %Y "$CACHE_FILE") )) -gt 900 ]; then
        # Fetch in background to avoid blocking hyprlock
        if [ ! -f "$LOCKED_FILE" ]; then
            touch "$LOCKED_FILE"
            (
                fetch_weather
                rm -f "$LOCKED_FILE"
            ) &
        fi
    fi
fi

# Print cached weather if available, otherwise fallback
if [ -f "$CACHE_FILE" ]; then
    cat "$CACHE_FILE"
else
    echo "Mumbai --°C"
fi
