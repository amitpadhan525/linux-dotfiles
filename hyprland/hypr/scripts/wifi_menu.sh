#!/bin/bash

# Toggle behavior: if already open, close it and exit
if pgrep -f "rofi.*󰤨  Wi-Fi" >/dev/null; then
    pkill -f "rofi.*󰤨  Wi-Fi"
    exit 0
fi

notify() {
    notify-send "Wi-Fi Menu" "$1"
}

# ── Write themes to temp files (avoids all shell quoting issues) ─────────────
THEME_FILE=$(mktemp /tmp/wifi-rofi-XXXXXX.rasi)
PASS_THEME_FILE=$(mktemp /tmp/wifi-pass-XXXXXX.rasi)
trap 'rm -f "$THEME_FILE" "$PASS_THEME_FILE"' EXIT

# ── Main Wi-Fi list theme — glassmorphic emerald design ───────────────────────
cat > "$THEME_FILE" << 'ROFI_THEME'
* {
    font:                "JetBrainsMono Nerd Font Bold 12";

    bg-base:             #020e0aa6;
    bg-alt:              #ffffff14;
    fg-main:             #ffffffff;
    fg-dim:              #a7f3d099;
    accent:              #34d399ff;
    accent-dim:          #34d39912;
    accent-mid:          #34d399b3;
    border-subtle:       #34d39933;
    urgent:              #f38ba8ff;

    background-color:    transparent;
    text-color:          @fg-main;
}

window {
    transparency:        "real";
    background-color:    @bg-base;
    border:              1px solid;
    border-color:        @accent-mid;
    border-radius:       22px;
    width:               520px;
    cursor:              "default";
}

mainbox {
    background-color:    transparent;
    children:            [ "inputbar", "listview" ];
    padding:             20px;
    spacing:             14px;
}

inputbar {
    background-color:    @bg-alt;
    border:              1px solid;
    border-color:        @accent;
    border-radius:       12px;
    padding:             12px 16px;
    spacing:             10px;
    children:            [ "prompt", "entry" ];
    text-color:          @fg-main;
}

prompt {
    background-color:    transparent;
    text-color:          @accent;
}

entry {
    background-color:    transparent;
    text-color:          @fg-main;
    cursor:              text;
    placeholder:         "Search networks…";
    placeholder-color:   @fg-dim;
}

listview {
    background-color:    transparent;
    columns:             1;
    lines:               9;
    cycle:               true;
    dynamic:             true;
    scrollbar:           false;
    layout:              vertical;
    spacing:             6px;
    fixed-height:        false;
}

scrollbar {
    width:               3px;
    border:              0px;
    handle-width:        3px;
    handle-color:        @accent;
    background-color:    @accent-dim;
}

element {
    background-color:    @accent-dim;
    border:              1px solid;
    border-color:        @border-subtle;
    border-radius:       10px;
    padding:             10px 14px;
    spacing:             12px;
    cursor:              pointer;
    text-color:          @fg-main;
}

element normal.normal {
    background-color:    @accent-dim;
    text-color:          @fg-main;
}

element alternate.normal {
    background-color:    @accent-dim;
    text-color:          @fg-main;
}

element selected.normal {
    background-color:    @accent;
    border-color:        @accent;
    text-color:          #020e0af5;
}

element normal.urgent {
    background-color:    #f38ba81a;
    border-color:        #f38ba866;
    text-color:          @urgent;
}

element selected.urgent {
    background-color:    @urgent;
    border-color:        @urgent;
    text-color:          #020e0af5;
}

element-icon {
    background-color:    transparent;
    text-color:          inherit;
    size:                20px;
    cursor:              inherit;
}

element-text {
    background-color:    transparent;
    text-color:          inherit;
    highlight:           inherit;
    cursor:              inherit;
    vertical-align:      0.5;
    horizontal-align:    0.0;
}
ROFI_THEME

# ── Password dialog theme ────────────────────────────────────────────────────
cat > "$PASS_THEME_FILE" << 'PASS_THEME'
* {
    font:                "JetBrainsMono Nerd Font Bold 12";

    bg-base:             #020e0aa6;
    bg-alt:              #ffffff14;
    fg-main:             #ffffffff;
    fg-dim:              #a7f3d099;
    accent:              #34d399ff;

    background-color:    transparent;
    text-color:          @fg-main;
}

window {
    transparency:        "real";
    background-color:    @bg-base;
    border:              1px solid;
    border-color:        #34d399b3;
    border-radius:       22px;
    width:               520px;
    cursor:              "default";
}

mainbox {
    background-color:    transparent;
    children:            [ "inputbar" ];
    padding:             24px;
    spacing:             0px;
}

inputbar {
    background-color:    @bg-alt;
    border:              1px solid;
    border-color:        @accent;
    border-radius:       12px;
    padding:             14px 16px;
    spacing:             12px;
    children:            [ "prompt", "entry" ];
}

prompt {
    background-color:    transparent;
    text-color:          @accent;
}

entry {
    background-color:    transparent;
    text-color:          @fg-main;
    cursor:              text;
    placeholder:         "Enter password…";
    placeholder-color:   @fg-dim;
}

listview { lines: 0; }
PASS_THEME

# ── Main logic ───────────────────────────────────────────────────────────────
CURRENT_SSID=$(nmcli -t -f active,ssid dev wifi list --rescan no 2>/dev/null | grep '^yes' | cut -d: -f2)
if [ -z "$CURRENT_SSID" ]; then
    CURRENT_SSID=$(nmcli -t -f TYPE,NAME connection show --active 2>/dev/null | grep '^802-11-wireless:' | cut -d: -f2-)
fi

STATE=$(nmcli -fields WIFI g 2>/dev/null | tail -n 1 | tr -d ' ')
if [ "$STATE" = "enabled" ]; then
    TOGGLE="󰖩  Disable Wi-Fi"
else
    TOGGLE="󰖪  Enable Wi-Fi"
fi

get_networks() {
    local rescan_mode="${1:-auto}"
    nmcli -t -f IN-USE,SIGNAL,BARS,SSID,SECURITY dev wifi list --rescan "$rescan_mode" 2>/dev/null | \
        sed 's/\\:/\x01/g' | \
        awk -F: '
        {
            ssid = $4;
            gsub(/\x01/, ":", ssid);
            if (ssid == "" || ssid == "--") next;
            if (!seen[ssid]++) {
                bars = $3;
                sec = $5;
                for (i = 6; i <= NF; i++) sec = sec ":" $i;
                gsub(/\x01/, ":", sec);
                printf "%s  %s  (%s)\n", bars, ssid, sec;
            }
        }'
}

SAVED_CONNECTIONS=$(nmcli -g NAME connection show 2>/dev/null)
WIFI_LIST=""

if [ "$STATE" = "enabled" ]; then
    WIFI_LIST=$(get_networks "auto")
    if [ -z "$WIFI_LIST" ]; then
        WIFI_LIST=$(get_networks "yes")
    fi
fi

get_password() {
    local target_ssid="$1"
    rofi -dmenu -password -p "󰌋  Password for $target_ssid" -theme "$PASS_THEME_FILE" \
        -location 2 -xoffset 0 -yoffset 48
}

OPTIONS="$TOGGLE\n󰑓  Rescan Networks\n󰢻  Open Connection Editor"
if [ -n "$CURRENT_SSID" ]; then
    DISCONNECT="󰌙  Disconnect from $CURRENT_SSID"
    OPTIONS="$TOGGLE\n$DISCONNECT\n󰑓  Rescan Networks\n󰢻  Open Connection Editor"
fi

if [ -n "$WIFI_LIST" ]; then
    OPTIONS="$OPTIONS\n$WIFI_LIST"
fi

# ── Run Rofi Directly & Reliably ─────────────────────────────────────────────
CHOSEN=$(echo -e "$OPTIONS" | rofi -dmenu -i -p '󰤨  Wi-Fi' -theme "$THEME_FILE" -location 2 -xoffset 0 -yoffset 48)

if [ -z "$CHOSEN" ]; then
    exit 0
elif [[ "$CHOSEN" == *"Enable Wi-Fi"* ]]; then
    nmcli radio wifi on
    notify "Wi-Fi Enabled"
elif [[ "$CHOSEN" == *"Disable Wi-Fi"* ]]; then
    nmcli radio wifi off
    notify "Wi-Fi Disabled"
elif [[ "$CHOSEN" == *"Rescan Networks"* ]]; then
    notify "Scanning for Wi-Fi networks..."
    nmcli dev wifi list --rescan yes >/dev/null 2>&1
    exec "$0" "$@"
elif [[ "$CHOSEN" == *"Disconnect from"* ]]; then
    ACTIVE_UUID=$(nmcli -t -f TYPE,UUID connection show --active 2>/dev/null | grep '^802-11-wireless:' | cut -d: -f2)
    if [ -n "$ACTIVE_UUID" ]; then
        notify "Disconnecting from $CURRENT_SSID..."
        if nmcli connection down uuid "$ACTIVE_UUID" 2>/dev/null; then
            notify "Disconnected from $CURRENT_SSID"
        else
            notify "Failed to disconnect"
        fi
    else
        notify "No active Wi-Fi connection found"
    fi
elif [[ "$CHOSEN" == *"Open Connection Editor"* ]]; then
    nm-connection-editor &
else
    RAW_SELECTION="${CHOSEN#*  }"
    SSID="${RAW_SELECTION%  (*}"
    SECURITY="${RAW_SELECTION##*  (}"
    SECURITY="${SECURITY%)}"

    if [ -z "$SSID" ]; then exit 0; fi

    if echo "$SAVED_CONNECTIONS" | grep -Fxq "$SSID"; then
        notify "Connecting to saved network: $SSID"
        if nmcli connection up "$SSID" 2>/dev/null; then
            notify "Connected to $SSID"
        else
            notify "Failed to connect to $SSID"
        fi
    else
        if [[ "$SECURITY" == *"WPA"* || "$SECURITY" == *"WEP"* || "$SECURITY" == *"802-11"* ]]; then
            PASS=$(get_password "$SSID")
            if [ -n "$PASS" ]; then
                notify "Connecting to $SSID..."
                if nmcli device wifi connect "$SSID" password "$PASS" 2>/dev/null; then
                    notify "Connected to $SSID"
                else
                    notify "Failed to connect to $SSID. Please check password."
                fi
            fi
        else
            notify "Connecting to $SSID..."
            if nmcli device wifi connect "$SSID" 2>/dev/null; then
                notify "Connected to $SSID"
            else
                notify "Failed to connect to $SSID"
            fi
        fi
    fi
fi
