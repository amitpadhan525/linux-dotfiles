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

# Instantly copy the image data to clipboard
if command -v wl-copy >/dev/null 2>&1; then
    wl-copy -t image/png < "$TMPFILE"
fi

FILENAME=$(rofi -dmenu -p "Save as (no extension):" -mesg "Leave blank to only copy" -theme "$HOME/.config/rofi/simple.rasi" -theme-str 'listview { lines: 0; } entry { placeholder: ""; }' < /dev/null)
if [[ -z "${FILENAME:-}" ]]; then
    rm -f "$TMPFILE"
    notify-send "Screenshot copied" "Saved to clipboard only"
    exit 0
fi
SAFE_NAME="$(echo "$FILENAME" | tr -cd '[:alnum:]._ -' | sed 's/^[ .-]*//;s/[ .-]*$//')"
if [[ -z "$SAFE_NAME" ]]; then
    rm -f "$TMPFILE"
    notify-send "Screenshot copied" "Saved to clipboard only"
    exit 0
fi
FINAL_PATH="$SAVE_DIR/${SAFE_NAME}.png"
if [[ -e "$FINAL_PATH" ]]; then
    COUNT=1
    while [[ -e "$SAVE_DIR/${SAFE_NAME}_$COUNT.png" ]]; do
        ((COUNT++))
    done
    FINAL_PATH="$SAVE_DIR/${SAFE_NAME}_$COUNT.png"
fi
mv "$TMPFILE" "$FINAL_PATH"
notify-send "Screenshot saved & copied" "$FINAL_PATH"
echo "$FINAL_PATH"