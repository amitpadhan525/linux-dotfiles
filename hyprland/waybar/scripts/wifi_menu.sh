#!/bin/bash

# Notify function
notify() {
    notify-send "Wi-Fi Menu" "$1"
}

# Rofi Configuration for "Drop Down" style
# Adjust x-offset if your network module is not at the very left
ROFI_CMD="rofi -dmenu -i -p 'Wi-Fi' -theme-str '
    window {
        location: north west;
        anchor: north west;
        x-offset: 100px; /* Adjust based on your bar/module position */
        y-offset: 40px;  /* Height of your waybar */
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

# Get current status
CURRENT_SSID=$(nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d: -f2)
STATE=$(nmcli -fields WIFI g | tail -n 1 | tr -d ' ')

if [ "$STATE" = "enabled" ]; then
    TOGGLE="睊  Disable Wi-Fi"
else
    TOGGLE="直  Enable Wi-Fi"
fi

# Get saved connections
SAVED_CONNECTIONS=$(nmcli -g NAME connection show)

# Get available networks
# Format: BARS  SSID  SECURITY
# We use awk to format it nicel
if [ "$STATE" = "enabled" ]; then
    WIFI_LIST=$(nmcli --colors no -f BARS,SSID,SECURITY dev wifi list | tail -n +2 | \
        awk -F'  +' '{ 
            if($2=="") next; # Skip empty SSIDs
            # Create readable entry
            printf "%s  %s  (%s)\n", $1, $2, $3 
        }' | sort -u)
fi

# Function to get password
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

# Prepare options
OPTIONS="$TOGGLE\n漣  Open Connection Editor\n$WIFI_LIST"

# Show Menu
CHOSEN=$(echo -e "$OPTIONS" | eval "$ROFI_CMD")

# Handle selection
if [ -z "$CHOSEN" ]; then
    exit 0
elif [ "$CHOSEN" = "直  Enable Wi-Fi" ]; then
    nmcli radio wifi on
    notify "Wi-Fi Enabled"
elif [ "$CHOSEN" = "睊  Disable Wi-Fi" ]; then
    nmcli radio wifi off
    notify "Wi-Fi Disabled"
elif [ "$CHOSEN" = "漣  Open Connection Editor" ]; then
    nm-connection-editor &
else
    # Extract SSID (remove signal bars and security)
    # The format was: BARS  SSID  (SECURITY)
    # field 2 onwards, until detected pattern or hard stop
    
    # Simple extraction strategy:
    # 1. Remove the first column (bars)
    # 2. Remove the last part in parens (security)
    # Keep it simple: nmcli output might vary, but let's try to pass the raw SSID to nmcli
    
    # Actually, a better way is to parse the chosen line.
    # Lines look like: "▂▄▆_  MyNetwork  (WPA2)"
    # SSID is in the middle.
    
    # Removing leading bars...
    RAW_SELECTION="${CHOSEN#*  }" 
    # RAW_SELECTION is now "MyNetwork  (WPA2)" or similar.
    
    # Removing trailing security info...
    SSID=$(echo "$RAW_SELECTION" | sed 's/  (.*)$//')
    
    # Trim whitespace
    SSID=$(echo "$SSID" | xargs)

    if [ -z "$SSID" ]; then exit 1; fi

    # Check if we have a saved connection for this SSID
    if echo "$SAVED_CONNECTIONS" | grep -q "^$SSID$"; then
        notify "Connecting to saved network: $SSID"
        if nmcli connection up "$SSID"; then
            notify "Connected to $SSID"
        else
            notify "Failed to connect to $SSID"
        fi
    else
        # New connection
        # Check security type from the list or assume password needed if not Open
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
            # Open network or Unknown
            notify "Connecting to $SSID..."
            if nmcli device wifi connect "$SSID"; then
                notify "Connected to $SSID"
            else
                notify "Failed to connect"
            fi
        fi
    fi
fi
