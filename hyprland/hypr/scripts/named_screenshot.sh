#!/usr/bin/env bash
set -euo pipefail
# Prevent multiple concurrent screenshot instances / stacked slurp overlays
exec 9>/tmp/named_screenshot.lock
flock -n 9 || exit 0

if pgrep -x slurp >/dev/null; then
    exit 0
fi

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

while true; do
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
        # File already exists, ask the user to rename or replace
        CHOICE=$(echo -e "Replace\nRename" | rofi -dmenu -p "File already exists" -theme "$HOME/.config/rofi/simple.rasi" -theme-str 'window { width: 450px; } listview { columns: 2; lines: 1; }' -i)
        
        if [[ "$CHOICE" == *"Replace"* ]]; then
            mv -f "$TMPFILE" "$FINAL_PATH"
            break
        elif [[ "$CHOICE" == *"Rename"* ]]; then
            continue
        else
            # User closed rofi or cancelled, default to clipboard only
            rm -f "$TMPFILE"
            notify-send "Screenshot copied" "Saved to clipboard only"
            exit 0
        fi
    else
        mv "$TMPFILE" "$FINAL_PATH"
        break
    fi
done

notify-send "Screenshot saved & copied" "$FINAL_PATH"
echo "$FINAL_PATH"