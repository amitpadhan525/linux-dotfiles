---@diagnostic disable: undefined-global
-- ----------------------------------------------------- 
-- HYPRLAND CONFIGURATION FILE (Lua Style)
-- ----------------------------------------------------- 

require("conf.environment")
require("conf.monitors")
require("conf.keyboard")
package.loaded["conf.customization"] = nil
require("conf.customization")
require("conf.windowrules")
require("conf.workspaces")
require("conf.keybinding")
require("conf.autostart")

