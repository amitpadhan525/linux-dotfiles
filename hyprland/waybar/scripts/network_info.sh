#!/bin/bash

# ----------------------------------------------------- 
# Network Information Script
# ----------------------------------------------------- 

# Check if nmcli (NetworkManager CLI) is available
if command -v nmcli >/dev/null 2>&1; then
  # Get the connected interface name
  iface=$(nmcli -t -f DEVICE,STATE device status | awk -F: '$2=="connected"{print $1; exit}')
  
  if [ -n "$iface" ]; then
    # Get Wifi SSID if connected via Wifi
    ssid=$(nmcli -t -f ACTIVE,SSID dev wifi | awk -F: '$1=="yes"{print $2; exit}')
    # Get IP address
    ip=$(nmcli -t -f IP4.ADDRESS device show "$iface" | sed -n 's/^IP4.ADDRESS://p' | cut -d/ -f1 | head -n1)
    
    if [ -n "$ssid" ]; then
      # Output for Wifi: Icon + SSID + IP
      printf " %s · %s\n" "${ssid:-?}" "${ip:-?}"
      exit 0
    else
      # Output for Ethernet: Icon + Interface + IP
      printf " %s · %s\n" "${iface:-?}" "${ip:-?}"
      exit 0
    fi
  fi
fi

# Fallback to ip command if nmcli is not found or fails
if command -v ip >/dev/null 2>&1; then
  # Get default interface
  iface=$(ip route get 1.1.1.1 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i=="dev") print $(i+1)}' | head -n1)
  # Get IP address of that interface
  ipaddr=$(ip -4 addr show "$iface" 2>/dev/null | awk '/inet /{print $2}' | cut -d/ -f1 | head -n1)
  
  if [ -n "$iface" ]; then
    printf " %s · %s\n" "$iface" "${ipaddr:-?}"
    exit 0
  fi
fi

# If no connection found
echo "offline"
