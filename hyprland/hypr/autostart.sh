#!/bin/bash
# Autostart helper for Hyprland
# Copy this file to ~/.config/hypr/autostart.sh and make it executable:
#   mkdir -p ~/.config/hypr
#   cp /home/amit/hypr/autostart.sh ~/.config/hypr/
#   chmod +x ~/.config/hypr/autostart.sh
# Then add in your hyprland.conf: exec-once = ~/.config/hypr/autostart.sh

# Start the items you use (uncomment lines you want).
# Note: don't start services twice if your distro already runs them.

# Waybar (status bar)
# waybar &

# Notification daemon (mako)
# mako &

# Pipewire audio
# pipewire &
# wireplumber &

# Clipboard manager (wl-clipboard / clipmenud)
# clipmenud &

# Restore wallpaper (example with nitrogen)
# nitrogen --restore &

# Background services you want to start in your session can go here.

exit 0
exec-once = /usr/bin/gnome-keyring-daemon --start --components=secrets
brave --enable-features=UseOzonePlatform --ozone-platform=wayland &
