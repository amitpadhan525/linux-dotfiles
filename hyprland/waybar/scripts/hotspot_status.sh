#!/bin/bash

# Check if the internal NetworkManager Hotspot connection is active
if nmcli -t -f NAME con show --active | grep -q "^Hotspot$"; then
    echo '{"text": "  Hotspot ON", "class": "active", "tooltip": "Hotspot is currently active. Click to turn off."}'
else
    echo '{"text": "  Hotspot OFF", "class": "inactive", "tooltip": "Hotspot is off. Click to turn on."}'
fi
