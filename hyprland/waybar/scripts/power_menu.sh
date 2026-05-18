#!/bin/bash

# ----------------------------------------------------- 
# Menu Options with Icons
# ----------------------------------------------------- 
lock="  Lock"
logout="󰗽  Logout"
suspend="  Suspend"
hibernate="󰒲  Hibernate"
reboot="  Reboot"
shutdown="  Shutdown"

# ----------------------------------------------------- 
# Rofi Configuration String
# ----------------------------------------------------- 
rofi_cmd() {
    timeout 5 rofi -dmenu \
        -theme-str '
* {
    font: "JetBrainsMono Nerd Font 13";
    background-color: transparent;
    text-color: #cdd6f4;
}
window {
    transparency: "real";
    background-color: rgba(8, 8, 13, 0.95);
    border: 1px solid;
    border-color: rgba(243, 139, 168, 0.6);
    border-radius: 12px;
    width: 160px;
    location: northeast;
    x-offset: -10px;
    y-offset: 45px;
}
mainbox {
    background-color: transparent;
    children: [ listview ];
    padding: 8px;
}
listview {
    background-color: transparent;
    columns: 1;
    lines: 6;
    spacing: 4px;
    cycle: true;
    dynamic: true;
    layout: vertical;
}
element {
    background-color: transparent;
    text-color: #cdd6f4;
    orientation: horizontal;
    border-radius: 6px;
    padding: 6px 10px;
    cursor: pointer;
}
element-text {
    background-color: transparent;
    text-color: inherit;
    cursor: inherit;
    vertical-align: 0.5;
}
element selected.normal {
    background-color: #f38ba8;
    text-color: #11111b;
}
'
}

# ----------------------------------------------------- 
# Execute Selected Command
# ----------------------------------------------------- 
run_cmd() {
    if [[ "$1" == *Lock* ]]; then
        hyprlock                          
    elif [[ "$1" == *Suspend* ]]; then
        systemctl suspend                 
    elif [[ "$1" == *Hibernate* ]]; then
        systemctl hibernate               
    elif [[ "$1" == *Logout* ]]; then
        killall Hyprland
    elif [[ "$1" == *Reboot* ]]; then
        systemctl reboot                  
    elif [[ "$1" == *Shutdown* ]]; then
        systemctl poweroff                
    fi
}

# ----------------------------------------------------- 
# Main Execution
# ----------------------------------------------------- 
chosen="$(echo -e "$lock\n$logout\n$suspend\n$hibernate\n$reboot\n$shutdown" | rofi_cmd)"

if [[ -n "$chosen" ]]; then
    run_cmd "$chosen"
fi
