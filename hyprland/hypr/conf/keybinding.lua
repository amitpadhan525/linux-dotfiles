---@diagnostic disable: undefined-global
local home = os.getenv("HOME")
local mainMod = "SUPER"

-- Applications
hl.bind("SUPER + E", hl.dsp.exec_cmd("thunar"))
hl.bind("SUPER + Return", hl.dsp.exec_cmd("kitty --config " .. home .. "/.config/kitty/kitty.conf"))
hl.bind("SUPER + D", hl.dsp.exec_cmd("rofi -show drun -theme " .. home .. "/.config/rofi/simple.rasi"))
hl.bind("SUPER + W", hl.dsp.exec_cmd(home .. "/.config/waybar/scripts/cycle_waybar.sh"))

-- System
hl.bind("SUPER + p", hl.dsp.exec_cmd(home .. "/.config/hypr/scripts/power_menu.sh"))
hl.bind("SUPER + N", hl.dsp.exec_cmd("bash -c 'pgrep hyprsunset && pkill hyprsunset || hyprsunset --temperature 4500'"))
hl.bind("SUPER + S", hl.dsp.exec_cmd(home .. "/.config/hypr/scripts/named_screenshot.sh"))
hl.bind("SUPER + SHIFT + S", hl.dsp.exec_cmd(home .. "/.config/hypr/scripts/screen_record.sh"))
hl.bind("SUPER + ALT + W", hl.dsp.exec_cmd(home .. "/.config/hypr/scripts/wallpaper.sh"))
hl.bind("SUPER + R", hl.dsp.exec_cmd("hyprctl reload"))
hl.bind("SUPER + l", hl.dsp.exec_cmd("hyprlock"))
hl.bind("SUPER + Q", hl.dsp.window.close())
hl.bind("SUPER + F", hl.dsp.window.float({ action = "toggle" }))
hl.bind("SUPER + space", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))


-- Workspaces
for i = 1, 9 do
    hl.bind("SUPER + " .. i, hl.dsp.focus({ workspace = i }))
    hl.bind("SUPER + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end

-- Mouse bindings
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Media keys
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("pamixer -i 5"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("pamixer -d 5"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("pamixer -t"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set +5%"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"), { locked = true, repeating = true })
