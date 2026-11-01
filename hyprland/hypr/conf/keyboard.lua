---@diagnostic disable: undefined-global
hl.config({
    input = {
        kb_layout = "us",
        repeat_rate = 50,
        repeat_delay = 300,
        follow_mouse = 1,
        mouse_refocus = true,
        float_switch_override_focus = 0,
        accel_profile = "flat",
        touchpad = {
            natural_scroll = true,
            tap_to_click = true,
            disable_while_typing = true,
            clickfinger_behavior = true,
            middle_button_emulation = true,
            scroll_factor = 1.0,
        }
    },
    gestures = {
        workspace_swipe_distance = 300,
        workspace_swipe_invert = true,
        workspace_swipe_cancel_ratio = 0.5,
        workspace_swipe_create_new = true,
        workspace_swipe_direction_lock = true,
    }
})

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

-- Disable companion ELAN mouse interface (prevents palm touches bypassing disable_while_typing)
hl.device({
    name = "elan071a:00-04f3:30fd-mouse",
    enabled = false,
})

-- Explicitly enforce disable_while_typing on the touchpad device
hl.device({
    name = "elan071a:00-04f3:30fd-touchpad",
    disable_while_typing = true,
    natural_scroll = true,
    tap_to_click = true,
})






