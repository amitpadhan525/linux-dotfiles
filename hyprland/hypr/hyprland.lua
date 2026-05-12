---@diagnostic disable: undefined-global
-- ----------------------------------------------------- 
-- HYPRLAND CONFIGURATION FILE (Lua Style)
-- ----------------------------------------------------- 

require("conf.environment")
require("conf.monitors")
require("conf.keyboard")
require("conf.customization")
require("conf.windowrules")
require("conf.workspaces")
require("conf.keybinding")
require("conf.autostart")

-- EMERGENCY OVERRIDE: Force tiling on workspaces 1-6
-- Using the most direct API calls to ensure this works regardless of modularization issues
for i = 1, 6 do
    hl.window_rule({ "tile", match = { workspace = tostring(i) } })
end

-- Force the portal (file picker) to tile globally on 1-6
hl.window_rule({ "tile", match = { class = "xdg-desktop-portal-gtk", workspace = "r[1-6]" } })
hl.window_rule({ "tile", match = { initial_class = "xdg-desktop-portal-gtk", workspace = "r[1-6]" } })
