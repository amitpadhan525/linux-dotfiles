---@diagnostic disable: undefined-global
local home = os.getenv("HOME")


-- Function to run autostart apps only if they aren't already running
local function autostart()
    -- Import environment variables to D-Bus and systemd before spawning any processes
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE QT_QPA_PLATFORMTHEME PATH")
    hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE QT_QPA_PLATFORMTHEME PATH")

    -- wallpaper.sh works around a hyprpaper v0.8.x bug where config wallpaper= is ignored
    hl.exec_cmd(home .. "/.config/hypr/scripts/wallpaper.sh &")

    local system_apps = {
        { name = "waybar", path = "waybar" },
        { name = "dunst", path = "dunst" },
        { name = "nm-applet", path = "nm-applet" },
        { name = "hyprpolkitagent", path = "/usr/lib/hyprpolkitagent/hyprpolkitagent" }
    }

    for _, app in ipairs(system_apps) do
        hl.exec_cmd("pgrep -x \"" .. app.name .. "\" > /dev/null || " .. app.path .. " &")
    end

    -- Run scripts directly (concurrency and single-instance locks are handled inside the scripts)
    hl.exec_cmd(home .. "/.config/hypr/scripts/battery-notification.sh &")
    hl.exec_cmd(home .. "/.config/hypr/scripts/device-notifier.sh &")
    hl.exec_cmd(home .. "/.config/hypr/scripts/clipboard-daemon.sh &")
end

-- Run only once on the very first startup
hl.on("hyprland.start", autostart)
