#!/bin/bash
notify() {
    notify-send "Wi-Fi Menu" "$1"
}
ROFI_CMD="rofi -dmenu -i -p 'Wi-Fi' -theme-str '
    window {
        location: north west;
        anchor: north west;
        x-offset: 100px;
        y-offset: 40px;
        width: 400px;
        border-radius: 10px;
        background-color: #1e1e2e;
        children: [ mainbox ];
        border: 2px;
        border-color: #b4befe;
    }
    mainbox {
        orientation: vertical;
        children: [ inputbar, listview ];
        spacing: 5px;
        padding: 10px;
    }
    inputbar {
        padding: 5px;
        background-color: transparent;
        text-color: #cdd6f4;
        children: [ prompt, entry ];
    }
    prompt {
        padding: 0px 5px 0px 0px;
        text-color: #89b4fa;
    }
    entry {
        placeholder: \"Search networks...\";
        text-color: #cdd6f4;
    }
    listview {
        lines: 10;
        spacing: 5px;
        scrollbar: false;
    }
    element {
        padding: 8px;
        border-radius: 5px;
        spacing: 10px;
    }
    element normal.normal {
        background-color: transparent;
        text-color: #cdd6f4;
    }
    element selected.normal {
        background-color: #89b4fa;
        text-color: #1e1e2e;
    }
    element-text {
        vertical-align: 0.5;
    }
    element-icon {
        size: 20px;
    }
'"
# Trigger an asynchronous scan in the background to update the cache for next time
nmcli dev wifi rescan &>/dev/null &

CURRENT_SSID=$(nmcli -t -f active,ssid dev wifi list --rescan no | grep '^yes' | cut -d: -f2)
STATE=$(nmcli -fields WIFI g | tail -n 1 | tr -d ' ')
if [ "$STATE" = "enabled" ]; then
    TOGGLE="e  Disable Wi-Fi"
else
    TOGGLE="8  Enable Wi-Fi"
fi
SAVED_CONNECTIONS=$(nmcli -g NAME connection show)
if [ "$STATE" = "enabled" ]; then
    WIFI_LIST=$(nmcli --colors no -f BARS,SSID,SECURITY dev wifi list --rescan no | tail -n +2 | \
        awk -F'  +' '{ 
            if($2=="") next;
            printf "%s  %s  (%s)\n", $1, $2, $3 
        }' | sort -u)
fi
get_password() {
    rofi -dmenu -password -p "Enter Password >" -theme-str '
        * {
            background-color: transparent;
            text-color: #cdd6f4;
        }
        window {
            width: 400px;
            padding: 20px;
            border: 2px;
            border-radius: 10px;
            border-color: #b4befe;
            background-color: #1e1e2e;
            location: center;
        }
        inputbar {
            children: [ prompt, entry ];
            spacing: 10px;
        }
        entry {
            placeholder: "Type password...";
            placeholder-color: #585b70;
            background-color: #313244;
            padding: 10px;
            border-radius: 5px;
            text-color: #cdd6f4;
        }
        prompt {
            padding: 10px 0;
            text-color: #89b4fa;
        }
        listview { lines: 0; }
    ' 
}
OPTIONS="$TOGGLE\n3  Open Connection Editor\n$WIFI_LIST"
CHOSEN=$(echo -e "$OPTIONS" | eval "$ROFI_CMD")
if [ -z "$CHOSEN" ]; then
    exit 0
elif [ "$CHOSEN" = "8  Enable Wi-Fi" ]; then
    nmcli radio wifi on
    notify "Wi-Fi Enabled"
elif [ "$CHOSEN" = "e  Disable Wi-Fi" ]; then
    nmcli radio wifi off
    notify "Wi-Fi Disabled"
elif [ "$CHOSEN" = "3  Open Connection Editor" ]; then
    nm-connection-editor &
else
    RAW_SELECTION="${CHOSEN#*  }" 
    SSID=$(echo "$RAW_SELECTION" | sed 's/  (.*)$//')
    SSID=$(echo "$SSID" | xargs)
    if [ -z "$SSID" ]; then exit 1; fi
    if echo "$SAVED_CONNECTIONS" | grep -q "^$SSID$"; then
        notify "Connecting to saved network: $SSID"
        if nmcli connection up "$SSID"; then
            notify "Connected to $SSID"
        else
            notify "Failed to connect to $SSID"
        fi
    else
        SECURITY=$(echo "$CHOSEN" | grep -o "([A-Za-z0-9 ]*)" | tr -d '()')
        if [[ "$SECURITY" == *"WPA"* || "$SECURITY" == *"WEP"* ]]; then
            PASS=$(get_password "$SSID")
            if [ -n "$PASS" ]; then
                notify "Connecting to $SSID..."
                if nmcli device wifi connect "$SSID" password "$PASS"; then
                    notify "Connected to $SSID"
                else
                    notify "Failed to connect. Wrong password?"
                fi
            fi
        else
            notify "Connecting to $SSID..."
            if nmcli device wifi connect "$SSID"; then
                notify "Connected to $SSID"
            else
                notify "Failed to connect"
            fi
        fi
    fi
fi
