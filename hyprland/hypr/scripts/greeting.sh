#!/bin/bash
# ----------------------------------------------------- 
# Dynamic Greeting script for hyprlock (Premium Edition)
# ----------------------------------------------------- 

h=$(date +%H)
if [ "$h" -lt 12 ]; then
    GREETING="GOOD MORNING"
elif [ "$h" -lt 18 ]; then
    GREETING="GOOD AFTERNOON"
else
    GREETING="GOOD EVENING"
fi

# Output with premium Pango markup letter spacing and accent highlight
echo "<span weight='light' letter_spacing='6000'>${GREETING}</span> <span foreground='#00ffb3'><b>AMIT</b></span>"
