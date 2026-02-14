#!/bin/bash

# Options
lock=" Lock"
logout="󰗽 Logout"
suspend=" Suspend"
hibernate="󰒲 Hibernate"
reboot=" Reboot"
shutdown=" Shutdown"

# Rofi CMD
rofi_cmd() {
    # timeout 5s kills rofi after 5 seconds if no selection is made
    timeout 5s rofi -dmenu \
        -p "Power" \
        -theme-str "
    * {
        font: \"JetBrainsMono Nerd Font 14\";
        background-color: #1e1e2e;
        foreground-color: #ffffff;
        accent-color: #89b4fa;
        urgent-color: #f38ba8;
        border-color: #b4befe;
    }

    window {
        transparency: \"real\";
        background-color: @background-color;
        text-color: @foreground-color;
        border: 2px;
        border-color: @border-color;
        border-radius: 12px;
        location: northeast;
        x-offset: -10px;
        y-offset: 45px;
        width: 220px;
    }

    inputbar {
        enabled: false;
    }

    mainbox {
        background-color: transparent;
        children: [ listview ];
        padding: 10px;
    }

    listview {
        background-color: transparent;
        columns: 1;
        lines: 6;
        spacing: 5px;
        cycle: true;
        dynamic: true;
        layout: vertical;
    }

    element {
        background-color: transparent;
        text-color: @foreground-color;
        orientation: horizontal;
        border-radius: 6px;
        padding: 10px 10px;
    }

    element-icon {
        background-color: transparent;
        text-color: inherit;
        size: 24px;
        border: 0px;
        margin: 0px 10px 0px 0px;
    }

    element-text {
        background-color: transparent;
        text-color: inherit;
        cursor: inherit;
        vertical-align: 0.5;
        horizontal-align: 0.0;
    }

    element selected.normal {
        background-color: @accent-color;
        text-color: #1e1e2e;
    }
    "
}

# Execute Command
run_cmd() {
    if [[ "$1" == "$lock" ]]; then
        swaylock
    elif [[ "$1" == "$suspend" ]]; then
        systemctl suspend
    elif [[ "$1" == "$hibernate" ]]; then
        systemctl hibernate
    elif [[ "$1" == "$logout" ]]; then
        hyprctl dispatch exit
    elif [[ "$1" == "$reboot" ]]; then
        systemctl reboot
    elif [[ "$1" == "$shutdown" ]]; then
        systemctl poweroff
    fi
}

# Actions
chosen="$(echo -e "$lock\n$logout\n$suspend\n$hibernate\n$reboot\n$shutdown" | rofi_cmd)"
run_cmd "$chosen"
