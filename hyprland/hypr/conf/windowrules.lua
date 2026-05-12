---@diagnostic disable: undefined-global

-- Force TILING and disable floating for workspaces 1-6
for i = 1, 6 do
    hl.window_rule({
        "tile",
        match = { workspace = tostring(i) },
        float = false
    })
end

-- Specifically target the file picker/portal to ensure it tiles on 1-6
for i = 1, 6 do
    hl.window_rule({
        "tile",
        match = { 
            class = "xdg-desktop-portal-gtk",
            workspace = tostring(i)
        },
        float = false
    })
    hl.window_rule({
        "tile",
        match = { 
            initial_class = "xdg-desktop-portal-gtk",
            workspace = tostring(i)
        },
        float = false
    })
end

-- Force FLOATING for workspaces 7-9
for i = 7, 9 do
    hl.window_rule({
        "float",
        match = { workspace = tostring(i) }
    })
end
