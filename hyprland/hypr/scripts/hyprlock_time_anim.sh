#!/bin/bash
TIME=$(date +"%I:%M")
SEC=$(date +"%S")
AMPM=$(date +"%p")
echo "$TIME<span size=\"102400\" foreground=\"#00ffff\">:$SEC</span><span size=\"61440\" foreground=\"#ffffff\"> $AMPM</span>"
