#!/bin/bash

# Configuration
# Usable Width: 1920 / 2 = 960. Subtract 2 for borders = 958.
# Usable Height: (1080 - 45) / 2 = 517. Subtract 2 for borders = 515.
HALF_W=958
HALF_H=515
FLOATING_WS_START=7
BAR_H=45

# Log file for debugging
LOG="/tmp/hypr_smart_key.log"

# Get current workspace and floating state
WS=$(hyprctl activeworkspace -j | jq '.id')
IS_FLOATING=$(hyprctl activewindow -j | jq '.floating')

# DIRECTION can be l, r, u, d
DIR=$1

echo "$(date): Action $DIR on Workspace $WS" >> $LOG

if [ "$WS" -lt "$FLOATING_WS_START" ]; then
    # NORMAL WORKSPACE: Move Focus
    echo "Tiled workspace: moving focus $DIR" >> $LOG
    hyprctl dispatch movefocus "$DIR"
else
    # FLOATING WORKSPACE: Snap to Corner
    echo "Floating workspace: snapping for $DIR" >> $LOG
    
    # Ensure window is floating
    if [ "$IS_FLOATING" = "false" ]; then
        echo "Toggling float for window" >> $LOG
        hyprctl dispatch togglefloating
        sleep 0.2 # Increased delay for better reliability
    fi

    # Calculated positions
    TOP_Y=$BAR_H
    BOTTOM_Y=$((BAR_H + HALF_H + 2))
    LEFT_X=0
    RIGHT_X=$((HALF_W + 2))

    case $DIR in
        "l") # Top Left
            hyprctl dispatch resizeactive exact $HALF_W $HALF_H
            hyprctl dispatch moveactive exact $LEFT_X $TOP_Y
            ;;
        "r") # Top Right
            hyprctl dispatch resizeactive exact $HALF_W $HALF_H
            hyprctl dispatch moveactive exact $RIGHT_X $TOP_Y
            ;;
        "d") # Bottom Left
            hyprctl dispatch resizeactive exact $HALF_W $HALF_H
            hyprctl dispatch moveactive exact $LEFT_X $BOTTOM_Y
            ;;
        "u") # Bottom Right
            hyprctl dispatch resizeactive exact $HALF_W $HALF_H
            hyprctl dispatch moveactive exact $RIGHT_X $BOTTOM_Y
            ;;
    esac
fi
