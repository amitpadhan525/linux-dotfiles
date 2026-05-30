#!/bin/bash
# ── Power Menu ────────────────────────────────────────────────
# Uses a dedicated rasi theme to avoid -theme-str quoting issues.
# ─────────────────────────────────────────────────────────────

THEME="$HOME/.config/rofi/power-menu.rasi"

# ── Menu Options ──
lock="  Lock"
logout="󰗽  Logout"
hibernate="󰒲  Hibernate"
reboot="  Reboot"
shutdown="  Shutdown"

# ── Show Menu ──
chosen=$(printf '%s\n' "$lock" "$logout" "$hibernate" "$reboot" "$shutdown" \
    | rofi -dmenu -p "" -theme "$THEME")

# ── Execute Selection ──
case "$chosen" in
    *Lock*)      hyprlock ;;
    *Logout*)    killall Hyprland ;;
    *Hibernate*) systemctl hibernate ;;
    *Reboot*)    systemctl reboot ;;
    *Shutdown*)  systemctl poweroff ;;
esac
