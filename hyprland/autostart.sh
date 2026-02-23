#!/bin/bash
exit 0
exec-once = /usr/bin/gnome-keyring-daemon --start --components=secrets
brave --enable-features=UseOzonePlatform --ozone-platform=wayland &
