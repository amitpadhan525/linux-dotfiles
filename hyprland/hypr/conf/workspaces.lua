---@diagnostic disable: undefined-global
-- Workspace rules (monitor assignments, smart gaps, etc.)

-- Smart Gaps: Remove outer & inner gaps when only 1 tiled window is present
hl.workspace_rule({ workspace = "w[tv1]", gaps_in = 0, gaps_out = 0 })
hl.workspace_rule({ workspace = "f[1]", gaps_in = 0, gaps_out = 0 })

-- Default monitor workspace bindings
hl.workspace_rule({ workspace = "1", monitor = "eDP-1" })
hl.workspace_rule({ workspace = "2", monitor = "HDMI-A-1" })







