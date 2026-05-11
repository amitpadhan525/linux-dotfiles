---@diagnostic disable: undefined-global

hl.on("hyprland.start", function()
    hl.exec_cmd("/home/amit/.config/hypr/scripts/wallpaper.sh")
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
    hl.exec_cmd("waybar")
    hl.exec_cmd("nm-applet --indicator")
    hl.exec_cmd("swaync")
end)
