#!/usr/bin/env bash

# Path to the notification log file
LOG_FILE="/home/amit/.config/hypr/logs/notifications.log"

# Get current timestamp
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

# Ensure log directory exists
mkdir -p "$(dirname "$LOG_FILE")"

# Avoid writing empty lines if values are missing
APP="${DUNST_APP_NAME:-Unknown}"
SUMMARY="${DUNST_SUMMARY:-}"
BODY="${DUNST_BODY:-}"
URGENCY="${DUNST_URGENCY:-LOW}"

# Clean up newlines in summary and body to keep log file clean (single line per notification)
SUMMARY=$(echo "$SUMMARY" | tr '\n' ' ')
BODY=$(echo "$BODY" | tr '\n' ' ')

# Log formatted notification
echo "[$TIMESTAMP] [$APP] [$URGENCY] $SUMMARY: $BODY" >> "$LOG_FILE"
