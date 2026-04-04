#!/bin/bash
shell=$(basename "$SHELL")
if [ "$shell" = "bash" ]; then
    file="$HOME/.bash_profile"
    if [ ! -f "$file" ]; then file="$HOME/.profile"; fi
    echo -e '\n# Autostart Hyprland\nif [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then\n    exec hyprland\nfi' >> "$file"
    echo "Configured $file"
elif [ "$shell" = "zsh" ]; then
    file="$HOME/.zprofile"
    echo -e '\n# Autostart Hyprland\nif [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then\n    exec hyprland\nfi' >> "$file"
    echo "Configured $file"
elif [ "$shell" = "fish" ]; then
    mkdir -p "$HOME/.config/fish"
    file="$HOME/.config/fish/config.fish"
    echo -e '\n# Autostart Hyprland\nif status is-login\n    if test -z "$DISPLAY" -a "$(tty)" = "/dev/tty1"\n        exec hyprland\n    end\nend' >> "$file"
    echo "Configured $file"
else
    echo "Unsupported shell: $shell. Please add the snippet manually."
fi
