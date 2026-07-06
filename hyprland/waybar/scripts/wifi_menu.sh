#!/bin/bash
notify() {
    notify-send "Wi-Fi Menu" "$1"
}

# ── Write themes to temp files (avoids all shell quoting issues) ─────────────
THEME_FILE=$(mktemp /tmp/wifi-rofi-XXXXXX.rasi)
PASS_THEME_FILE=$(mktemp /tmp/wifi-pass-XXXXXX.rasi)
trap 'rm -f "$THEME_FILE" "$PASS_THEME_FILE"' EXIT

# ── Main Wi-Fi list theme — mirrors simple.rasi design language ──────────────
cat > "$THEME_FILE" << 'ROFI_THEME'
/*******************************************************************************
 * Wi-Fi Menu — Neon Teal #00ffb3
 * Mirrors simple.rasi (Super+D launcher) design language exactly
 ******************************************************************************/

* {
    font:                "JetBrainsMono Nerd Font Bold 12";

    bg-base:             #000000ff;
    bg-alt:              #ffffff14;
    fg-main:             #ffffffff;
    fg-dim:              #888888ff;
    accent:              #00ffb3ff;
    accent-dim:          #00ffb30a;
    accent-mid:          #00ffb3b3;
    border-subtle:       #00ffb333;
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
    text-color:          #000000ff;
}

element normal.urgent {
    background-color:    #f38ba81a;
    border-color:        #f38ba866;
    text-color:          @urgent;
}

element selected.urgent {
    background-color:    @urgent;
    border-color:        @urgent;
    text-color:          #000000ff;
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

    bg-base:             #000000ff;
    bg-alt:              #ffffff14;
    fg-main:             #ffffffff;
    fg-dim:              #888888ff;
    accent:              #00ffb3ff;

    background-color:    transparent;
    text-color:          @fg-main;
}

window {
    transparency:        "real";
    background-color:    @bg-base;
    border:              1px solid;
    border-color:        #00ffb3b3;
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
nmcli dev wifi rescan &>/dev/null &

CURRENT_SSID=$(nmcli -t -f active,ssid dev wifi list --rescan no | grep '^yes' | cut -d: -f2)
if [ -z "$CURRENT_SSID" ]; then
    CURRENT_SSID=$(nmcli -t -f TYPE,NAME connection show --active | grep '^802-11-wireless:' | cut -d: -f2-)
fi
STATE=$(nmcli -fields WIFI g | tail -n 1 | tr -d ' ')
if [ "$STATE" = "enabled" ]; then
    TOGGLE="Disable Wi-Fi"
else
    TOGGLE="Enable Wi-Fi"
fi
SAVED_CONNECTIONS=$(nmcli -g NAME connection show)
if [ "$STATE" = "enabled" ]; then
    WIFI_LIST=$(nmcli -t -f BARS,SSID,SECURITY dev wifi list --rescan no | \
        sed 's/\\:/\x01/g' | \
        awk -F: '{
            if($2=="") next;
            gsub(/\x01/, ":", $2);
            printf "%s  %s  (%s)\n", $1, $2, $3
        }' | sort -u)
fi

get_password() {
    rofi -dmenu -password -p "  Password" -theme "$PASS_THEME_FILE" \
        -location 2 -xoffset 0 -yoffset 48
}

if [ -n "$CURRENT_SSID" ]; then
    DISCONNECT="Disconnect from $CURRENT_SSID"
    OPTIONS="$TOGGLE\n$DISCONNECT\nOpen Connection Editor\n$WIFI_LIST"
else
    OPTIONS="$TOGGLE\nOpen Connection Editor\n$WIFI_LIST"
fi

# ── Launch rofi in background for idle watchdog support ────────────────────
OPTS_FILE=$(mktemp /tmp/wifi-opts-XXXXXX.txt)
CHOSEN_FILE=$(mktemp /tmp/wifi-chosen-XXXXXX.txt)
trap 'rm -f "$THEME_FILE" "$PASS_THEME_FILE" "$OPTS_FILE" "$CHOSEN_FILE"' EXIT
echo -e "$OPTIONS" > "$OPTS_FILE"

rofi -dmenu -i -p '󰤨  Wi-Fi' -theme "$THEME_FILE" \
    -location 2 -xoffset 0 -yoffset 48 \
    < "$OPTS_FILE" > "$CHOSEN_FILE" &
ROFI_PID=$!

# ── Hyprland IPC focus watchdog ───────────────────────────────────────────────
# nc -U reads from the Hyprland event socket. Any activewindow>> event after
# rofi is open means another window gained focus (user clicked outside).
HYPR_SOCK="$XDG_RUNTIME_DIR/hypr/${HYPRLAND_INSTANCE_SIGNATURE}/.socket2.sock"
# ── Auto-detect socket if HYPRLAND_INSTANCE_SIGNATURE is missing ─────────────
if [ ! -S "$HYPR_SOCK" ]; then
    HYPR_SOCK=$(ls "$XDG_RUNTIME_DIR/hypr/"*"/.socket2.sock" 2>/dev/null | head -1)
fi
DBG="/tmp/wifi-watchdog-debug.log"
echo "[$(date +%T)] ROFI_PID=$ROFI_PID" > "$DBG"
echo "[$(date +%T)] HYPR_SOCK=$HYPR_SOCK" >> "$DBG"
echo "[$(date +%T)] Socket exists: $([ -S "$HYPR_SOCK" ] && echo YES || echo NO)" >> "$DBG"
(
    sleep 1
    echo "[$(date +%T)] Watchdog started, connecting to socket..." >> "$DBG"
    nc -U "$HYPR_SOCK" 2>>"$DBG" | \
    while IFS= read -r event; do
        echo "[$(date +%T)] EVENT: $event" >> "$DBG"
        kill -0 "$ROFI_PID" 2>/dev/null || { echo "[$(date +%T)] rofi gone, exiting" >> "$DBG"; break; }
        case "$event" in
            activewindow\>\>*)
                CLASS=$(printf '%s' "$event" | cut -d'>' -f3 | cut -d',' -f1)
                echo "[$(date +%T)] activewindow class=$CLASS" >> "$DBG"
                [ "$CLASS" != "rofi" ] && [ -n "$CLASS" ] && {
                    echo "[$(date +%T)] Killing rofi (class=$CLASS)" >> "$DBG"
                    kill "$ROFI_PID" 2>/dev/null
                    break
                }
                ;;
        esac
    done
    echo "[$(date +%T)] Watchdog loop ended" >> "$DBG"
) &
FOCUS_PID=$!

# ── Cursor-idle safety net (backup: closes after 30s of no mouse movement) ───
(
    IDLE_COUNT=0
    LAST_POS=$(hyprctl cursorpos 2>/dev/null)
    while kill -0 "$ROFI_PID" 2>/dev/null; do
        sleep 1
        CURR_POS=$(hyprctl cursorpos 2>/dev/null)
        if [ "$CURR_POS" != "$LAST_POS" ]; then
            IDLE_COUNT=0; LAST_POS="$CURR_POS"
        else
            IDLE_COUNT=$((IDLE_COUNT + 1))
            [ "$IDLE_COUNT" -ge 30 ] && kill "$ROFI_PID" 2>/dev/null && break
        fi
    done
) &
IDLE_PID=$!

wait "$ROFI_PID" 2>/dev/null
kill "$FOCUS_PID" "$IDLE_PID" 2>/dev/null
wait "$FOCUS_PID" "$IDLE_PID" 2>/dev/null

CHOSEN=$(cat "$CHOSEN_FILE")

if [ -z "$CHOSEN" ]; then
    exit 0
elif [ "$CHOSEN" = "Enable Wi-Fi" ]; then
    nmcli radio wifi on
    notify "Wi-Fi Enabled"
elif [ "$CHOSEN" = "Disable Wi-Fi" ]; then
    nmcli radio wifi off
    notify "Wi-Fi Disabled"
elif [ "$CHOSEN" = "Disconnect from $CURRENT_SSID" ]; then
    ACTIVE_UUID=$(nmcli -t -f TYPE,UUID connection show --active | grep '^802-11-wireless:' | cut -d: -f2)
    if [ -n "$ACTIVE_UUID" ]; then
        notify "Disconnecting from $CURRENT_SSID..."
        if nmcli connection down uuid "$ACTIVE_UUID"; then
            notify "Disconnected from $CURRENT_SSID"
        else
            notify "Failed to disconnect"
        fi
    else
        notify "No active Wi-Fi connection found"
    fi
elif [ "$CHOSEN" = "Open Connection Editor" ]; then
    nm-connection-editor &
else
    RAW_SELECTION="${CHOSEN#*  }"
    SSID=$(echo "$RAW_SELECTION" | sed 's/  ([^)]*)$//')
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
