#!/bin/bash
pkill hyprpaper
sleep 1
hyprpaper &
sleep 2
hyprctl hyprpaper preload "/home/amit/.config/hypr/spiderman.jpeg"
hyprctl hyprpaper wallpaper "eDP-1,/home/amit/.config/hypr/spiderman.jpeg"
