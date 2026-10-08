# Font
font_family      monospace
font_size        12.5

# Colors
background       #000000
foreground       #ffffff

# Cursor
cursor_shape     beam
cursor_blink_interval 0.5

# Window
window_padding_width 8

# Scrollback
scrollback_lines 10000

# Performance
repaint_delay    8
input_delay      1
sync_to_monitor  yes

# Keybinds
kitty_mod        ctrl+shift
map ctrl+equal   change_font_size current +2
map ctrl+minus   change_font_size current -2
map ctrl+0       change_font_size current 0