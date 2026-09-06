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
local accent_hex = dyn_colors.accent_hex or "34d399"
local accent_two_hex = dyn_colors.accent_two_hex or "6ee7b7"

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
    render = {
        direct_scanout = 1
    },
    decoration = {
        rounding = 5,
        shadow = {
            enabled = false
        },
        blur = {
            enabled = true,
            size = 6,
            passes = 1,
            vibrancy = 0.1696,
            new_optimizations = true,
            xray = true,
            popups = true,
            ignore_opacity = true
        }
    },
    animations = {
        enabled = true
    },
    misc = {
        disable_autoreload = false,
        force_default_wallpaper = 0,
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        vrr = 1,
        middle_click_paste = false,
        animate_manual_resizes = false,
        animate_mouse_windowdragging = false
    },
    group = {
        groupbar = {
            disable_when_only = true,
            height = 20,
            font_size = 10
        }
    },
    cursor = {
        inactive_timeout = 3,
        no_warps = true
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
