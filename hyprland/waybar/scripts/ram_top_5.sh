#!/bin/bash
processes=$(ps axch -o cmd:15,rss --sort=-rss | awk '{printf "%-15s %4.0f MB\n", $1, $2/1024}' | head -n 5)
notify-send "Top 5 RAM Processes" "$processes"
