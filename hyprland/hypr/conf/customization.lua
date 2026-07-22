---@diagnostic disable: undefined-global

local function get_dynamic_colors()
    local colors = {}
    local path = (os.getenv("HOME") or "") .. "/.config/hypr/colors.conf"
    local f = io.open(path, "r")
    if f then
        for line in f:lines() do
            local k, v = line:match("^%s*%$([%w_]+)%s*=%s*(.-)%s*$")
            if k and v then
                colors[k] = v
            end
        end
        f:close()
    end
    return colors
end

local dyn_colors = get_dynamic_colors()
local accent_hex = dyn_colors.accent_hex or "00ffb3"
local accent_two_hex = dyn_colors.accent_two_hex or "a7f3d0"

local active_border = "rgba(" .. accent_hex .. "e6)"
local inactive_border = "rgba(" .. accent_hex .. "20)"

hl.config({
    general = {
        gaps_in = 1,
        gaps_out = 0,
        border_size = 1,
        col = {
            active_border = active_border,
            inactive_border = inactive_border,
        },
        resize_on_border = true,
        layout = "dwindle"
    },
    decoration = {
        rounding = 5,
        shadow = {
            enabled = true,
            range = 4,
            render_power = 3,
            color = "rgba(1a1a1aee)",
        },
        blur = {
            enabled = true,
            size = 8,
            passes = 2,
            vibrancy = 0.1696
        }
    },
    animations = {
        enabled = true
    },
    misc = {
        disable_autoreload = false,
        force_default_wallpaper = 0,
        disable_hyprland_logo = true,
        vrr = 0,
        animate_manual_resizes = true,
        animate_mouse_windowdragging = true
    },
    group = {
        groupbar = {
            disable_when_only = true,
            height = 20,
            font_size = 10
        }
    }
})

hl.curve("myBezier", { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.05} } })

hl.animation({ leaf = "windows", enabled = true, speed = 5, bezier = "myBezier" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 5, bezier = "myBezier" })
hl.animation({ leaf = "layers", enabled = true, speed = 5, bezier = "myBezier" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 5, bezier = "myBezier" })
hl.animation({ leaf = "border", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 8, bezier = "default" })
hl.animation({ leaf = "fade", enabled = true, speed = 5, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 5, bezier = "myBezier", style = "slidefade 20%" })
