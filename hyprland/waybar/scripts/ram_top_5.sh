#!/bin/bash
processes=$(ps axch -o cmd:15,%mem --sort=-%mem | head -n 5)
notify-send "Top 5 RAM Processes" "$processes"
