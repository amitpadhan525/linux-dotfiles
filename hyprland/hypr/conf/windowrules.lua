---@diagnostic disable: undefined-global

-- ─────────────────────────────────────────────────────────────────────────────
-- WINDOW RULES: FORCE TILING (Workspaces 1-6)
-- ─────────────────────────────────────────────────────────────────────────────

for i = 1, 6 do
    hl.window_rule({ match = { workspace = tostring(i) }, tile = true })
end

-- ─────────────────────────────────────────────────────────────────────────────
-- WINDOW RULES: FORCE FLOATING (Workspaces 7-9)
-- ─────────────────────────────────────────────────────────────────────────────

for i = 7, 9 do
    hl.window_rule({ match = { workspace = tostring(i) }, float = true })
end

-- ─────────────────────────────────────────────────────────────────────────────
-- TARGETED APP OVERRIDES: FORCE TILE BY CLASS
-- ─────────────────────────────────────────────────────────────────────────────

local forced_tiling_apps = {
    "code", "Code", "thunar", "dolphin", "nautilus",
    "org.gnome.Nautilus", "pcmanfm", "xdg-desktop-portal-gtk"
}

for _, app in ipairs(forced_tiling_apps) do
    hl.window_rule({ match = { class = app }, tile = true })
end

-- ─────────────────────────────────────────────────────────────────────────────
-- FILE DIALOG CATCH: by initial_title
-- NOTE: correct Lua prop is initial_title (snake_case), NOT initialTitle
-- ─────────────────────────────────────────────────────────────────────────────

local dialog_titles = {
    "Open File", "Save File", "Open Folder", "Save As",
    "Open", "Save", "Select File", "Select Folder",
}

for _, t in ipairs(dialog_titles) do
    hl.window_rule({ match = { initial_title = t }, tile = true })
end

-- ─────────────────────────────────────────────────────────────────────────────
-- GTK FILE CHOOSER: by initial_class
-- NOTE: correct Lua prop is initial_class (snake_case), NOT initialClass
-- ─────────────────────────────────────────────────────────────────────────────

hl.window_rule({ match = { initial_class = "xdg-desktop-portal-gtk" }, tile = true })
hl.window_rule({ match = { initial_class = "xdg-desktop-portal" }, tile = true })

-- ─────────────────────────────────────────────────────────────────────────────
-- MODAL/POPUP DIALOGS: force tile
-- 'modal' prop catches GTK/Qt popups and dialogs natively in v0.55
-- ─────────────────────────────────────────────────────────────────────────────

hl.window_rule({ match = { modal = true }, tile = true })

-- ─────────────────────────────────────────────────────────────────────────────
-- XWAYLAND FLOATING CATCH: force tile for any XWayland window trying to float
-- ─────────────────────────────────────────────────────────────────────────────

hl.window_rule({ match = { xwayland = true, float = true }, tile = true })

-- ─────────────────────────────────────────────────────────────────────────────
-- LAYER RULES: GLASSMORPHIC BLUR FOR DUNST NOTIFICATIONS
-- ─────────────────────────────────────────────────────────────────────────────
hl.layer_rule({ match = { namespace = "dunst" }, blur = true })
hl.layer_rule({ match = { namespace = "dunst" }, ignore_alpha = 0.2 })

-- ─────────────────────────────────────────────────────────────────────────────
-- LAYER RULES: GLASSMORPHIC BLUR FOR ROFI
-- ─────────────────────────────────────────────────────────────────────────────
hl.layer_rule({ match = { namespace = "rofi" }, blur = true })
hl.layer_rule({ match = { namespace = "rofi" }, ignore_alpha = 0.2 })

-- ─────────────────────────────────────────────────────────────────────────────
-- LAYER RULES: GLASSMORPHIC BLUR FOR WAYBAR
-- ─────────────────────────────────────────────────────────────────────────────
hl.layer_rule({ match = { namespace = "waybar" }, blur = true })
hl.layer_rule({ match = { namespace = "waybar" }, ignore_alpha = 0.01 })

-- ─────────────────────────────────────────────────────────────────────────────
-- LAYER RULES: GLASSMORPHIC BLUR FOR POWERMENU
-- ─────────────────────────────────────────────────────────────────────────────
hl.layer_rule({ match = { namespace = "powermenu" }, blur = true })
hl.layer_rule({ match = { namespace = "powermenu" }, ignore_alpha = 0.02 })