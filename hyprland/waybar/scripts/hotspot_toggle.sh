#!/bin/bash

SSID="ARCH-LINUX"
PASSWORD="1010101010"

# Extract the physical Wi-Fi interface (ignoring ap0 or virtual interfaces)
WIFI_IF=$(iw dev | awk '$1=="Interface"{print $2}' | grep -v "^ap" | head -n 1)

if [ -z "$WIFI_IF" ]; then
    notify-send "Hotspot Error" "No Wi-Fi interface found."
    exit 1
fi

# 1. If Hotspot is already active, simply turn it OFF
if nmcli -t -f NAME con show --active | grep -q "^Hotspot$"; then
    nmcli con down Hotspot
    notify-send "Hotspot" "Turned OFF"
    exit 0
fi

# 2. Prevent Hotspot from turning on if connected to a normal Wi-Fi network.
# Check if any ACTIVE connection is '802-11-wireless' AND is NOT named 'Hotspot'
ACTIVE_WIFI=$(nmcli -t -f NAME,TYPE con show --active | grep -E ":802-11-wireless|:wifi" | grep -v "^Hotspot:" | cut -d: -f1)

if [ -n "$ACTIVE_WIFI" ]; then
    notify-send "Hotspot Blocked" "Cannot turn on Hotspot while connected to Wi-Fi network: $ACTIVE_WIFI"
    exit 1
fi

# 3. Clean up any stale hotspot profiles
if nmcli -t -f NAME con show | grep -q "^Hotspot$"; then
    nmcli con delete Hotspot &>/dev/null
fi

# 4. Create new backward-compatible Hostspot using pure nmcli (Internal tools)
notify-send "Hotspot" "Starting AP mode via Ethernet connection..."

nmcli con add type wifi ifname "$WIFI_IF" con-name Hotspot autoconnect no ssid "$SSID"
nmcli con modify Hotspot 802-11-wireless.mode ap 802-11-wireless.band bg ipv4.method shared ipv6.method disabled
nmcli con modify Hotspot 802-11-wireless-security.key-mgmt wpa-psk 802-11-wireless-security.psk "$PASSWORD"
nmcli con modify Hotspot 802-11-wireless-security.proto rsn
nmcli con modify Hotspot 802-11-wireless-security.pairwise ccmp
nmcli con modify Hotspot 802-11-wireless-security.group ccmp
nmcli con modify Hotspot 802-11-wireless-security.pmf 1
nmcli con modify Hotspot 802-11-wireless.channel 6

# 5. Start the Hotspot
if nmcli con up Hotspot; then
    notify-send "Hotspot" "Turned ON\nSSID: $SSID\nPassword: $PASSWORD"
else
    notify-send "Hotspot Error" "Failed to start Hotspot using standard settings."
fi
