---@diagnostic disable: undefined-global

-- ─────────────────────────────────────────────────────────────────────────────
-- WINDOW RULES: Force TILING on workspaces 1-6
-- ─────────────────────────────────────────────────────────────────────────────

-- One rule per workspace to ensure tiling is always applied
hl.window_rule({ "tile", match = { workspace = "1" } })
hl.window_rule({ "tile", match = { workspace = "2" } })
hl.window_rule({ "tile", match = { workspace = "3" } })
hl.window_rule({ "tile", match = { workspace = "4" } })
hl.window_rule({ "tile", match = { workspace = "5" } })
hl.window_rule({ "tile", match = { workspace = "6" } })

-- Tile common floating offenders globally (file pickers, dialogs, etc.)
hl.window_rule({ "tile", match = { class = "xdg-desktop-portal-gtk" } })
hl.window_rule({ "tile", match = { class = "thunar" } })
hl.window_rule({ "tile", match = { class = "nemo" } })
hl.window_rule({ "tile", match = { class = "nautilus" } })
hl.window_rule({ "tile", match = { class = "dolphin" } })
hl.window_rule({ "tile", match = { class = "pcmanfm" } })

-- ─────────────────────────────────────────────────────────────────────────────
-- WINDOW RULES: Force FLOATING on workspaces 7-9
-- ─────────────────────────────────────────────────────────────────────────────
hl.window_rule({ "float", match = { workspace = "7" } })
hl.window_rule({ "float", match = { workspace = "8" } })
hl.window_rule({ "float", match = { workspace = "9" } })
