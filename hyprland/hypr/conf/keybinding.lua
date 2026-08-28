---@diagnostic disable: undefined-global
local home = os.getenv("HOME")
local mainMod = "SUPER"

-- Applications
hl.bind("SUPER + E", hl.dsp.exec_cmd("hyprfm"))
hl.bind("SUPER + SHIFT + E", hl.dsp.exec_cmd("hyprfm --new-window"))
hl.bind("SUPER + Return", hl.dsp.exec_cmd("kitty --config " .. home .. "/.config/kitty/kitty.conf"))
hl.bind("SUPER + D", hl.dsp.exec_cmd("rofi -show drun -theme " .. home .. "/.config/rofi/simple.rasi"))
hl.bind("SUPER + W", hl.dsp.exec_cmd(home .. "/.config/waybar/scripts/cycle_waybar.sh"))
hl.bind("SUPER + V", hl.dsp.exec_cmd("cliphist list | rofi -dmenu -i -p '📋 Clipboard' -theme " .. home .. "/.config/rofi/clipboard.rasi | cliphist decode | wl-copy"))

-- Window Focus (Vim & Arrow keys)
hl.bind("SUPER + H", hl.dsp.focus({ direction = "left" }))
hl.bind("SUPER + L", hl.dsp.focus({ direction = "right" }))
hl.bind("SUPER + K", hl.dsp.focus({ direction = "up" }))
hl.bind("SUPER + J", hl.dsp.focus({ direction = "down" }))
hl.bind("SUPER + Left", hl.dsp.focus({ direction = "left" }))
hl.bind("SUPER + Right", hl.dsp.focus({ direction = "right" }))
hl.bind("SUPER + Up", hl.dsp.focus({ direction = "up" }))
hl.bind("SUPER + Down", hl.dsp.focus({ direction = "down" }))

-- Window Movement / Swap (Vim & Arrow keys)
hl.bind("SUPER + SHIFT + H", hl.dsp.window.move({ direction = "left" }))
hl.bind("SUPER + SHIFT + L", hl.dsp.window.move({ direction = "right" }))
hl.bind("SUPER + SHIFT + K", hl.dsp.window.move({ direction = "up" }))
hl.bind("SUPER + SHIFT + J", hl.dsp.window.move({ direction = "down" }))
hl.bind("SUPER + SHIFT + Left", hl.dsp.window.move({ direction = "left" }))
hl.bind("SUPER + SHIFT + Right", hl.dsp.window.move({ direction = "right" }))
hl.bind("SUPER + SHIFT + Up", hl.dsp.window.move({ direction = "up" }))
hl.bind("SUPER + SHIFT + Down", hl.dsp.window.move({ direction = "down" }))

-- Window State & Control
hl.bind("SUPER + Q", hl.dsp.window.close())
hl.bind("SUPER + F", hl.dsp.window.float({ action = "toggle" }))
hl.bind("SUPER + space", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))

-- Window Groups (Tabs)
hl.bind("SUPER + G", hl.dsp.group.toggle())
hl.bind("SUPER + TAB", hl.dsp.group.next())
hl.bind("SUPER + SHIFT + TAB", hl.dsp.group.prev())

-- Scratchpad (Special Workspace)
hl.bind("SUPER + U", hl.dsp.workspace.toggle_special("scratchpad"))
hl.bind("SUPER + SHIFT + U", hl.dsp.window.move({ workspace = "special:scratchpad" }))
hl.bind("SUPER + SHIFT + Return", hl.dsp.exec_cmd("bash -c 'hyprctl clients | grep -q \"class: scratchpad\" && hyprctl dispatch togglespecialworkspace scratchpad || kitty --class scratchpad'"))

-- System
hl.bind("SUPER + p", hl.dsp.exec_cmd(home .. "/.config/hypr/scripts/power_menu.sh"))
hl.bind("SUPER + N", hl.dsp.exec_cmd("bash -c 'pgrep hyprsunset && pkill hyprsunset || hyprsunset --temperature 4500'"))
hl.bind("SUPER + S", hl.dsp.exec_cmd(home .. "/.config/hypr/scripts/named_screenshot.sh"))
hl.bind("SUPER + SHIFT + S", hl.dsp.exec_cmd(home .. "/.config/hypr/scripts/screen_record.sh"))
hl.bind("SUPER + ALT + W", hl.dsp.exec_cmd(home .. "/.config/hypr/scripts/wallpaper.sh"))
hl.bind("SUPER + R", hl.dsp.exec_cmd("hyprctl reload"))
hl.bind("SUPER + l", hl.dsp.exec_cmd("hyprlock"))
hl.bind("switch:on:Lid Switch", hl.dsp.exec_cmd("hyprlock"), { locked = true })
hl.bind("XF86PowerOff", hl.dsp.exec_cmd("hyprlock"), { locked = true })
hl.bind("SUPER + ALT + l", hl.dsp.exec_raw("clear_crashed_lockscreen"))

-- Workspaces
for i = 1, 9 do
    hl.bind("SUPER + " .. i, hl.dsp.focus({ workspace = i }))
    hl.bind("SUPER + SHIFT + " .. i, hl.dsp.window.move({ workspace = i }))
end

-- Mouse bindings
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Media keys
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(home .. "/.config/hypr/scripts/volume_brightness_notify.sh volume_up"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(home .. "/.config/hypr/scripts/volume_brightness_notify.sh volume_down"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd(home .. "/.config/hypr/scripts/volume_brightness_notify.sh volume_mute"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd(home .. "/.config/hypr/scripts/volume_brightness_notify.sh brightness_up"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(home .. "/.config/hypr/scripts/volume_brightness_notify.sh brightness_down"), { locked = true, repeating = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
hl.bind("XF86AudioStop", hl.dsp.exec_cmd("playerctl stop"), { locked = true })

