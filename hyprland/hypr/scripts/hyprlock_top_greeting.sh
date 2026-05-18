#!/bin/bash
HOUR=$(date +%H)
if [ "$HOUR" -ge 5 ] && [ "$HOUR" -lt 12 ]; then
    GREETING="Good Morning,"
elif [ "$HOUR" -ge 12 ] && [ "$HOUR" -lt 17 ]; then
    GREETING="Good Afternoon,"
elif [ "$HOUR" -ge 17 ] && [ "$HOUR" -lt 21 ]; then
    GREETING="Good Evening,"
else
    GREETING="Good Night,"
fi
echo "<span foreground=\"#00ffff\"><b>$GREETING</b></span> Developer Amit"
