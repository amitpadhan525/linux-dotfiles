---@diagnostic disable: undefined-global

-- Function to run autostart apps only if they aren't already running
local function autostart()
    -- wallpaper.sh already handles its own killing/restarting
    hl.exec_cmd("/home/amit/.config/hypr/scripts/wallpaper.sh")
    
    local apps = {
        "waybar",
        "dunst",
        "nm-applet",
        "/usr/lib/hyprpolkitagent/hyprpolkitagent",
        "/home/amit/.config/hypr/scripts/battery-notification.sh",
        "/home/amit/.config/hypr/scripts/device-notifier.py"
    }
    
    for _, app in ipairs(apps) do
        local bin = app:match("([^/]+)$") or app
        local pgrep_opt = app:find("/") and "-f" or "-x"
        hl.exec_cmd("pgrep " .. pgrep_opt .. " " .. bin .. " > /dev/null || " .. app .. " &")
    end
    
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
end

-- Run only once on the very first startup
hl.on("hyprland.start", autostart)


-- On reload, we only want to refresh the wallpaper
-- We don't call autostart() here to avoid duplicate logic
hl.on("config.reloaded", function()
    hl.exec_cmd("/home/amit/.config/hypr/scripts/wallpaper.sh")
end)

-- Note: We removed the top-level autostart() call to prevent double execution during reload.
