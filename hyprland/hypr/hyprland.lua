---@diagnostic disable: undefined-global
-- ----------------------------------------------------- 
-- HYPRLAND CONFIGURATION FILE (Lua Style)
-- ----------------------------------------------------- 

local config_dir = os.getenv("HOME") .. "/.config/hypr/"
package.path = config_dir .. "?.lua;" .. config_dir .. "?/init.lua;" .. package.path

require("conf.environment")
require("conf.monitors")
require("conf.keyboard")
package.loaded["conf.customization"] = nil
require("conf.customization")
require("conf.windowrules")
require("conf.workspaces")
require("conf.keybinding")
require("conf.autostart")

