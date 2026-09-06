#!/usr/bin/env bash
# Screen Recorder Script for Hyprland using wf-recorder and rofi

set -euo pipefail

# 1. Check if wf-recorder is installed
if ! command -v wf-recorder >/dev/null 2>&1; then
    notify-send -u critical "Screen Recorder Error" "wf-recorder is not installed.\nInstall it using: sudo pacman -S wf-recorder"
    exit 1
fi

SAVE_DIR="$HOME/Videos/Recordings"
PID_FILE="/tmp/wf-recorder.pid"
PATH_FILE="/tmp/wf-recorder.path"

# 2. Check if recording is already active
if pgrep -u "$USER" -x "wf-recorder" >/dev/null; then
    # Get the PID
    PID=$(pgrep -u "$USER" -x "wf-recorder")
    
    # Stop recording gracefully
    kill -2 "$PID"
    
    # Wait for wf-recorder to finish writing the file
    while pgrep -u "$USER" -x "wf-recorder" >/dev/null; do
        sleep 0.2
    done

    # Clean up and notify
    if [ -f "$PATH_FILE" ]; then
        TEMP_PATH=$(cat "$PATH_FILE")
    else
        TEMP_PATH=""
    fi
    rm -f "$PID_FILE" "$PATH_FILE"
    
    # Force refresh Waybar so the status module updates immediately
    pkill -RTMIN+8 waybar || true
    
    if [ -f "$TEMP_PATH" ]; then
        SAVED_PATH=""
        while true; do
            # Prompt user to enter a name for the video file using a super compact single-line Rofi input box (starts empty)
            USER_NAME=$(echo "" | rofi -dmenu -p "Save as (empty for default)" -theme "$HOME/.config/rofi/simple.rasi" -theme-str 'listview { enabled: false; } window { width: 500px; }' -i)
            
            if [ -z "$USER_NAME" ]; then
                SAVED_PATH="$TEMP_PATH"
                break
            fi
            
            TARGET_PATH="$SAVE_DIR/${USER_NAME}.mp4"
            if [ -f "$TARGET_PATH" ]; then
                # File already exists, ask the user to rename or replace
                CHOICE=$(echo -e "Replace\nRename" | rofi -dmenu -p "File already exists" -theme "$HOME/.config/rofi/simple.rasi" -theme-str 'window { width: 450px; } listview { columns: 2; lines: 1; }' -i)
                
                if [[ "$CHOICE" == *"Replace"* ]]; then
                    SAVED_PATH="$TARGET_PATH"
                    mv -f "$TEMP_PATH" "$SAVED_PATH"
                    break
                elif [[ "$CHOICE" == *"Rename"* ]]; then
                    continue
                else
                    # User closed rofi, fallback to default temp file
                    SAVED_PATH="$TEMP_PATH"
                    break
                fi
            else
                SAVED_PATH="$TARGET_PATH"
                mv "$TEMP_PATH" "$SAVED_PATH"
                break
            fi
        done
        
        notify-send -t 5000 "Recording Saved" "Video saved to:\n$SAVED_PATH"
    else
        notify-send -t 5000 "Recording Saved" "Recording completed."
    fi
    
    exit 0
fi

# 3. Present Rofi menu to select recording mode in a beautiful compact pill format
# Fullscreen is the first option and is selected by default
OPTIONS="🖥️ Record Fullscreen\n📹 Record Area\n❌ Cancel"
CHOICE=$(echo -e "$OPTIONS" | rofi -dmenu -p "Screen Recorder" -theme "$HOME/.config/rofi/simple.rasi" -theme-str 'window { width: 450px; } listview { columns: 1; lines: 3; }' -i)

case "$CHOICE" in
    *"Record Fullscreen"*)
        # Prepare save directory and filename
        mkdir -p "$SAVE_DIR"
        TIMESTAMP=$(date +'%Y-%m-%d_%H-%M-%S')
        FINAL_PATH="$SAVE_DIR/recording_$TIMESTAMP.mp4"
        
        # Start recording full screen
        wf-recorder -f "$FINAL_PATH" >/dev/null 2>&1 &
        REC_PID=$!
        
        # Save PID and path for stopping later
        echo "$REC_PID" > "$PID_FILE"
        echo "$FINAL_PATH" > "$PATH_FILE"
        
        # Notify
        notify-send -t 4000 "Recording Started" "Recording full screen.\nClick the Waybar indicator or press SUPER+SHIFT+S to stop."
        
        # Force refresh Waybar
        pkill -RTMIN+8 waybar || true
        ;;
        
    *"Record Area"*)
        # Let user select region
        if ! command -v slurp >/dev/null 2>&1; then
            notify-send -u critical "Screen Recorder Error" "slurp is not installed."
            exit 1
        fi
        
        GEOM=$(slurp 2>/dev/null)
        if [ -z "$GEOM" ]; then
            notify-send "Recording Cancelled" "No area selected."
            exit 0
        fi
        
        # Prepare save directory and filename
        mkdir -p "$SAVE_DIR"
        TIMESTAMP=$(date +'%Y-%m-%d_%H-%M-%S')
        FINAL_PATH="$SAVE_DIR/recording_$TIMESTAMP.mp4"
        
        # Start recording the selected area
        wf-recorder -g "$GEOM" -f "$FINAL_PATH" >/dev/null 2>&1 &
        REC_PID=$!
        
        # Save PID and path for stopping later
        echo "$REC_PID" > "$PID_FILE"
        echo "$FINAL_PATH" > "$PATH_FILE"
        
        # Notify
        notify-send -t 4000 "Recording Started" "Recording selected area.\nClick the Waybar indicator or press SUPER+SHIFT+S to stop."
        
        # Force refresh Waybar
        pkill -RTMIN+8 waybar || true
        ;;
        
    *)
        # Cancelled or closed rofi without matching
        exit 0
        ;;
esac
