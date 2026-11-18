#!/bin/bash

# Toggle behavior: if rofi is already open, close it and exit cleanly
if pgrep -f "rofi.*Wi-Fi" >/dev/null; then
    pkill -f "rofi.*Wi-Fi"
    exit 0
fi

# Avoid overlapping instances if clicked in rapid succession
LOCK_FILE="/tmp/wifi_menu.lock"
exec 200>"$LOCK_FILE"
if ! flock -n 200; then
    exit 0
fi

notify() {
    notify-send "Wi-Fi Menu" "$1"
}

# ── Persistent theme files (avoids generating ~200 lines to disk on every click) ──
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/wifi-menu"
mkdir -p "$CACHE_DIR"
THEME_FILE="$CACHE_DIR/wifi-rofi.rasi"
PASS_THEME_FILE="$CACHE_DIR/wifi-pass.rasi"
COLOR_STAMP="$CACHE_DIR/color_stamp"

# Load dynamic theme colors if available
COLORS_FILE="$HOME/.config/hypr/colors.sh"
if [ -f "$COLORS_FILE" ]; then
    # shellcheck source=/dev/null
    source "$COLORS_FILE"
fi

ACCENT_HEX="${accent:-#34d399}"
BG_HEX="${bg_color:-#020e0a}"
FG_DIM_HEX="${secondary_text:-#a7f3d0}"
FAIL_HEX="${fail_color:-#f87171}"

CURRENT_COLOR_SIG="${ACCENT_HEX}_${BG_HEX}_${FG_DIM_HEX}_${FAIL_HEX}"
CACHED_COLOR_SIG=$(cat "$COLOR_STAMP" 2>/dev/null || true)

if [ ! -f "$THEME_FILE" ] || [ ! -f "$PASS_THEME_FILE" ] || [ "$CURRENT_COLOR_SIG" != "$CACHED_COLOR_SIG" ]; then
    echo "$CURRENT_COLOR_SIG" > "$COLOR_STAMP"
    cat > "$THEME_FILE" << ROFI_THEME
* {
    font:                "JetBrainsMono Nerd Font Bold 12";

    bg-base:             ${BG_HEX}a6;
    bg-alt:              #ffffff14;
    fg-main:             #ffffffff;
    fg-dim:              ${FG_DIM_HEX}99;
    accent:              ${ACCENT_HEX}ff;
    accent-dim:          ${ACCENT_HEX}12;
    accent-mid:          ${ACCENT_HEX}b3;
    border-subtle:       ${ACCENT_HEX}33;
    urgent:              ${FAIL_HEX}ff;

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
    text-color:          ${BG_HEX}f5;
}

element normal.urgent {
    background-color:    ${FAIL_HEX}1a;
    border-color:        ${FAIL_HEX}66;
    text-color:          @urgent;
}

element selected.urgent {
    background-color:    @urgent;
    border-color:        @urgent;
    text-color:          ${BG_HEX}f5;
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

    cat > "$PASS_THEME_FILE" << PASS_THEME
* {
    font:                "JetBrainsMono Nerd Font Bold 12";

    bg-base:             ${BG_HEX}a6;
    bg-alt:              #ffffff14;
    fg-main:             #ffffffff;
    fg-dim:              ${FG_DIM_HEX}99;
    accent:              ${ACCENT_HEX}ff;

    background-color:    transparent;
    text-color:          @fg-main;
}

window {
    transparency:        "real";
    background-color:    @bg-base;
    border:              1px solid;
    border-color:        ${ACCENT_HEX}b3;
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
fi

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

# ── Stream networks in real time into Rofi ──────────────────────────────────
# 1. Shows actions and cached networks instantly (<0.05s).
# 2. Streams newly discovered networks dynamically as hardware scan discovers them.
stream_networks() {
    # Send menu actions first
    echo -e "$OPTIONS"

    if [ "$STATE" = "enabled" ]; then
        local -A seen_ssids

        # Step 1: Immediately emit cached networks (zero delay)
        while IFS=$'\t' read -r bars ssid sec; do
            [ -z "$ssid" ] && continue
            if [ -z "${seen_ssids["$ssid"]}" ]; then
                seen_ssids["$ssid"]=1
                echo "$bars  $ssid  ($sec)"
            fi
        done < <(nmcli -t -f IN-USE,SIGNAL,BARS,SSID,SECURITY dev wifi list --rescan no 2>/dev/null | sed 's/\\:/\x01/g' | awk -F: '
            {
                bars = $3; ssid = $4; sec = $5;
                for (i = 6; i <= NF; i++) sec = sec ":" $i;
                gsub(/\x01/, ":", ssid);
                gsub(/\x01/, ":", sec);
                if (ssid != "" && ssid != "--") print bars "\t" ssid "\t" sec;
            }')

        # Step 2: Trigger hardware rescan and stream new networks as they appear
        while IFS=$'\t' read -r bars ssid sec; do
            [ -z "$ssid" ] && continue
            if [ -z "${seen_ssids["$ssid"]}" ]; then
                seen_ssids["$ssid"]=1
                echo "$bars  $ssid  ($sec)"
            fi
        done < <(nmcli -t -f IN-USE,SIGNAL,BARS,SSID,SECURITY dev wifi list --rescan yes 2>/dev/null | sed 's/\\:/\x01/g' | awk -F: '
            {
                bars = $3; ssid = $4; sec = $5;
                for (i = 6; i <= NF; i++) sec = sec ":" $i;
                gsub(/\x01/, ":", ssid);
                gsub(/\x01/, ":", sec);
                if (ssid != "" && ssid != "--") print bars "\t" ssid "\t" sec;
            }')

        # Step 3: Keep rescanning periodically as long as Rofi remains open
        while pgrep -f "rofi.*Wi-Fi" >/dev/null 2>&1; do
            sleep 4
            pgrep -f "rofi.*Wi-Fi" >/dev/null 2>&1 || break
            while IFS=$'\t' read -r bars ssid sec; do
                [ -z "$ssid" ] && continue
                if [ -z "${seen_ssids["$ssid"]}" ]; then
                    seen_ssids["$ssid"]=1
                    echo "$bars  $ssid  ($sec)"
                fi
            done < <(nmcli -t -f IN-USE,SIGNAL,BARS,SSID,SECURITY dev wifi list --rescan yes 2>/dev/null | sed 's/\\:/\x01/g' | awk -F: '
                {
                    bars = $3; ssid = $4; sec = $5;
                    for (i = 6; i <= NF; i++) sec = sec ":" $i;
                    gsub(/\x01/, ":", ssid);
                    gsub(/\x01/, ":", sec);
                    if (ssid != "" && ssid != "--") print bars "\t" ssid "\t" sec;
                }')
        done
    fi
}

# ── Run Rofi with Asynchronous Streaming ─────────────────────────────────────
CHOSEN=$(stream_networks | rofi -dmenu -i -p '󰤨  Wi-Fi' -theme "$THEME_FILE" -location 2 -xoffset 0 -yoffset 48)

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

    # Fetch saved connections lazily only after selection
    SAVED_CONNECTIONS=$(nmcli -g NAME connection show 2>/dev/null)

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
