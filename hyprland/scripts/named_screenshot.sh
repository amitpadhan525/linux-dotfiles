#!/usr/bin/env bash
set -euo pipefail
SAVE_DIR="$HOME/Pictures/Screenshots"
mkdir -p "$SAVE_DIR"
TMPDIR="${TMPDIR:-/tmp}"
set +e
GEOM=$(slurp 2>/dev/null)
SLURP_EXIT=$?
set -e
if [[ $SLURP_EXIT -ne 0 || -z "$GEOM" ]]; then
    notify-send "Screenshot cancelled" "No area selected"
    exit 0
fi
TMPFILE="$(mktemp "$TMPDIR/screenshot_XXXXXX.png")"
grim -g "$GEOM" "$TMPFILE"
FILENAME=$(rofi -dmenu -p "Save as (no extension):" -mesg "Leave blank for timestamp")
if [[ -z "${FILENAME:-}" ]]; then
    FILENAME="screenshot_$(date +%Y%m%d_%H%M%S)"
fi
SAFE_NAME="$(echo "$FILENAME" | tr -cd '[:alnum:]._ -' | sed 's/^[ .-]*//;s/[ .-]*$//')"
[[ -z "$SAFE_NAME" ]] && SAFE_NAME="screenshot_$(date +%Y%m%d_%H%M%S)"
FINAL_PATH="$SAVE_DIR/${SAFE_NAME}.png"
if [[ -e "$FINAL_PATH" ]]; then
    COUNT=1
    while [[ -e "$SAVE_DIR/${SAFE_NAME}_$COUNT.png" ]]; do
        ((COUNT++))
    done
    FINAL_PATH="$SAVE_DIR/${SAFE_NAME}_$COUNT.png"
fi
mv "$TMPFILE" "$FINAL_PATH"
if command -v wl-copy >/dev/null 2>&1; then
    printf '%s' "$FINAL_PATH" | wl-copy
    notify-send "Screenshot saved" "$FINAL_PATH (path copied)"
else
    notify-send "Screenshot saved" "$FINAL_PATH"
fi
echo "$FINAL_PATH"