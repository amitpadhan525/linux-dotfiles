---@diagnostic disable: undefined-global

-- Function to run autostart apps only if they aren't already running
local function autostart()
    -- Import environment variables to D-Bus and systemd before spawning any processes
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")

    -- wallpaper.sh already handles its own killing/restarting
    hl.exec_cmd("/home/amit/.config/hypr/scripts/wallpaper.sh")
    
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
    hl.exec_cmd("/home/amit/.config/hypr/scripts/battery-notification.sh &")
    hl.exec_cmd("/home/amit/.config/hypr/scripts/device-notifier.sh &")
end

-- Run only once on the very first startup
hl.on("hyprland.start", autostart)


-- On reload, we only want to refresh the wallpaper
-- We don't call autostart() here to avoid duplicate logic
hl.on("config.reloaded", function()
    hl.exec_cmd("/home/amit/.config/hypr/scripts/wallpaper.sh")
end)

-- Note: We removed the top-level autostart() call to prevent double execution during reload.
