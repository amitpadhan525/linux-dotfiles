#!/usr/bin/env python3
import gi
gi.require_version('Gtk', '3.0')
gi.require_version('GtkLayerShell', '0.1')
from gi.repository import Gtk, Gdk, GtkLayerShell, GLib
import sys
import os
import subprocess
import re

# 1. Parse system theme colors
def parse_colors():
    colors = {
        'accent': '#00ffb3',
        'accent_two': '#a7f3d0',
        'bg_color': '#010403',
        'text_color': '#ffffff',
        'secondary_text': '#e0fcf0',
        'check_color': '#10b981',
        'fail_color': '#f87171'
    }
    try:
        colors_file = os.path.expanduser('~/.config/hypr/colors.sh')
        if os.path.exists(colors_file):
            with open(colors_file, 'r') as f:
                for line in f:
                    m = re.match(r'^\s*([a-zA-Z0-9_]+)=[\'"]?([^\'"\s]+)[\'"]?', line)
                    if m:
                        colors[m.group(1)] = m.group(2)
    except Exception as e:
        print(f"Error parsing colors: {e}", file=sys.stderr)
    return colors

colors = parse_colors()

def hex_to_rgba(hex_str, alpha):
    hex_str = hex_str.lstrip('#')
    if len(hex_str) == 3:
        hex_str = ''.join([c*2 for c in hex_str])
    try:
        r = int(hex_str[0:2], 16)
        g = int(hex_str[2:4], 16)
        b = int(hex_str[4:6], 16)
        return f"rgba({r}, {g}, {b}, {alpha})"
    except Exception:
        return f"rgba(0, 0, 0, {alpha})"

# Set CSS colors dynamically
accent = colors['accent']
accent_two = colors['accent_two']
bg_color = colors['bg_color']
text_color = colors['text_color']
accent_rgba_dim = hex_to_rgba(accent, 0.05)
accent_rgba_hover = hex_to_rgba(accent, 0.1)
accent_rgba_glow = hex_to_rgba(accent, 0.35)
bg_rgba_fullscreen = "rgba(0, 0, 0, 0.05)" # Low alpha to trigger full-screen blur
bg_rgba_dialog = hex_to_rgba(bg_color, 0.85) # Centered compact dialog background
timer_border_color = hex_to_rgba(accent, 0.25)
card_border_color = hex_to_rgba(accent, 0.15)
accent_two_dim = hex_to_rgba(accent_two, 0.3)
text_rgba_dim_footer = hex_to_rgba(text_color, 0.35)

CSS_TEMPLATE = f"""
* {{
    font-family: 'Outfit', sans-serif;
}}

.root-box {{
    background-color: {bg_rgba_fullscreen};
    transition: all 0.4s ease;
}}

.powermenu-dialog {{
    background-color: {bg_rgba_dialog};
    border: 1px solid {card_border_color};
    border-radius: 24px;
    padding: 30px 45px;
    box-shadow: 0 15px 45px rgba(0, 0, 0, 0.6), 0 0 40px rgba(0, 255, 179, 0.04);
}}

.powermenu-container {{
    margin: 0px;
}}

.title-label {{
    font-size: 28px;
    font-weight: 800;
    color: {text_color};
    letter-spacing: 4px;
    margin-bottom: 5px;
    text-shadow: 0 0 15px rgba(255, 255, 255, 0.15);
}}

.subtitle-label {{
    font-size: 13px;
    font-weight: 300;
    color: {accent_two};
    letter-spacing: 2px;
    margin-bottom: 20px;
    opacity: 0.8;
}}

.timer-box {{
    background-color: {accent_rgba_dim};
    border: 1px solid {timer_border_color};
    border-radius: 30px;
    padding: 10px 24px;
    margin-bottom: 35px;
    box-shadow: 0 0 20px rgba(0, 255, 179, 0.1);
}}

.timer-label {{
    font-size: 15px;
    font-weight: 500;
    color: {accent_two};
    letter-spacing: 2px;
}}

.timer-highlight {{
    color: {accent};
    font-weight: 800;
    text-shadow: 0 0 10px rgba(0, 255, 179, 0.5);
}}

.cards-box {{
    margin-bottom: 35px;
}}

.power-card {{
    background-color: {accent_rgba_dim};
    border: 1px solid {card_border_color};
    border-radius: 16px;
    padding: 25px 15px;
    min-width: 110px;
    min-height: 125px;
    margin: 6px 0px;
    transition: all 0.3s cubic-bezier(0.16, 1, 0.3, 1);
}}

.power-card:hover {{
    background-color: {accent_rgba_hover};
    border-color: {accent};
    box-shadow: 0 0 35px {accent_rgba_glow};
    margin-top: 0px;
    margin-bottom: 12px;
}}

.card-icon {{
    font-family: 'JetBrainsMono Nerd Font', 'Outfit';
    font-size: 38px;
    font-weight: bold;
    color: rgba(0, 255, 179, 0.6);
    margin-bottom: 12px;
    transition: all 0.3s cubic-bezier(0.16, 1, 0.3, 1);
}}

.power-card:hover .card-icon {{
    color: {accent};
    font-size: 44px;
    text-shadow: 0 0 25px {accent_rgba_glow};
}}

.card-label {{
    font-size: 12px;
    font-weight: 800;
    color: rgba(255, 255, 255, 0.65);
    letter-spacing: 1.5px;
    transition: all 0.3s cubic-bezier(0.16, 1, 0.3, 1);
}}

.power-card:hover .card-label {{
    color: #ffffff;
    text-shadow: 0 0 15px rgba(255, 255, 255, 0.4);
}}

.card-hotkey {{
    font-size: 10px;
    font-weight: 600;
    color: {accent_two_dim};
    margin-top: 6px;
    transition: all 0.3s cubic-bezier(0.16, 1, 0.3, 1);
}}

.power-card:hover .card-hotkey {{
    color: {accent};
}}

.footer-label {{
    font-size: 12px;
    font-weight: 300;
    color: {text_rgba_dim_footer};
    letter-spacing: 1.5px;
}}
"""

class PowerMenuWindow(Gtk.Window):
    def __init__(self):
        super().__init__(title="Power Menu")
        self.set_name("powermenu-window")
        self.countdown_seconds = 30
        self.timer_id = None

        # Wayland Layer Shell Initialization
        GtkLayerShell.init_for_window(self)
        GtkLayerShell.set_layer(self, GtkLayerShell.Layer.OVERLAY)
        GtkLayerShell.set_keyboard_mode(self, GtkLayerShell.KeyboardMode.EXCLUSIVE)
        GtkLayerShell.set_namespace(self, "powermenu")

        # Fullscreen anchoring
        GtkLayerShell.set_anchor(self, GtkLayerShell.Edge.LEFT, True)
        GtkLayerShell.set_anchor(self, GtkLayerShell.Edge.RIGHT, True)
        GtkLayerShell.set_anchor(self, GtkLayerShell.Edge.TOP, True)
        GtkLayerShell.set_anchor(self, GtkLayerShell.Edge.BOTTOM, True)

        # Build UI
        self.build_ui()

        # Connect event handlers
        self.connect("key-press-event", self.on_key_press)
        
        # Start Countdown Timer
        self.start_timer()

    def build_ui(self):
        # Root Event Box to catch background clicks
        root_eb = Gtk.EventBox()
        root_eb.get_style_context().add_class("root-box")
        root_eb.connect("button-press-event", self.on_bg_clicked)
        self.add(root_eb)

        # Outer centering box
        outer_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
        outer_box.set_valign(Gtk.Align.CENTER)
        outer_box.set_halign(Gtk.Align.CENTER)
        root_eb.add(outer_box)

        # Dialog Box container (Compact centered panel)
        dialog_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
        dialog_box.get_style_context().add_class("powermenu-dialog")
        outer_box.pack_start(dialog_box, False, False, 0)

        # Sub-container
        container = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
        container.get_style_context().add_class("powermenu-container")
        container.set_halign(Gtk.Align.CENTER)
        dialog_box.pack_start(container, True, True, 0)

        # Header Title
        title_lbl = Gtk.Label(label="SYSTEM POWER MENU")
        title_lbl.get_style_context().add_class("title-label")
        container.pack_start(title_lbl, False, False, 0)

        # Header Subtitle
        sub_lbl = Gtk.Label(label="Select an operation or let the system shut down")
        sub_lbl.get_style_context().add_class("subtitle-label")
        container.pack_start(sub_lbl, False, False, 0)

        # Timer Indicator
        self.timer_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL)
        self.timer_box.get_style_context().add_class("timer-box")
        self.timer_box.set_halign(Gtk.Align.CENTER)
        
        self.timer_lbl = Gtk.Label()
        self.timer_lbl.set_use_markup(True)
        self.timer_lbl.get_style_context().add_class("timer-label")
        self.update_timer_label()
        
        self.timer_box.pack_start(self.timer_lbl, True, True, 0)
        container.pack_start(self.timer_box, False, False, 0)

        # Action Cards Box (Horizontal)
        cards_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=16)
        cards_box.get_style_context().add_class("cards-box")
        cards_box.set_halign(Gtk.Align.CENTER)
        container.pack_start(cards_box, False, False, 0)

        # Actions definitions: (Icon, Label, Hotkey, Command, Callback)
        self.actions = [
            ("", "SHUTDOWN", "S", "systemctl poweroff", self.action_shutdown),
            ("", "REBOOT", "R", "systemctl reboot", self.action_reboot),
            ("", "LOCK", "L", "hyprlock", self.action_lock),
            ("󰍃", "LOGOUT", "E", "hyprctl dispatch exit 0", self.action_logout),
            ("󰏤", "HIBERNATE", "H", "systemctl hibernate", self.action_hibernate),
            ("", "CANCEL", "Esc", "", self.action_cancel)
        ]

        for icon, label, hotkey, cmd, callback in self.actions:
            card_btn = Gtk.Button()
            card_btn.get_style_context().add_class("power-card")
            card_btn.set_relief(Gtk.ReliefStyle.NONE)
            card_btn.connect("clicked", lambda w, cb=callback: cb())

            # Card inner layout
            card_inner = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
            card_inner.set_valign(Gtk.Align.CENTER)
            card_inner.set_halign(Gtk.Align.CENTER)

            icon_lbl = Gtk.Label(label=icon)
            icon_lbl.get_style_context().add_class("card-icon")
            card_inner.pack_start(icon_lbl, False, False, 0)

            label_lbl = Gtk.Label(label=label)
            label_lbl.get_style_context().add_class("card-label")
            card_inner.pack_start(label_lbl, False, False, 0)

            hotkey_lbl = Gtk.Label(label=f"[{hotkey}]" if hotkey != "Esc" else "[Esc]")
            hotkey_lbl.get_style_context().add_class("card-hotkey")
            card_inner.pack_start(hotkey_lbl, False, False, 0)

            card_btn.add(card_inner)
            cards_box.pack_start(card_btn, False, False, 0)

        # Footer Label
        footer_lbl = Gtk.Label(label="Use mouse or keyboard hotkeys to select • Press ESC to cancel")
        footer_lbl.get_style_context().add_class("footer-label")
        container.pack_start(footer_lbl, False, False, 0)

    def update_timer_label(self):
        markup = f"Shutting down automatically in <span foreground='#ffffff' weight='bold'>{self.countdown_seconds}s</span>"
        self.timer_lbl.set_markup(markup)

    def start_timer(self):
        if self.timer_id:
            GLib.source_remove(self.timer_id)
        self.timer_id = GLib.timeout_add_seconds(1, self.on_timer_tick)

    def stop_timer(self):
        if self.timer_id:
            GLib.source_remove(self.timer_id)
            self.timer_id = None

    def on_timer_tick(self):
        self.countdown_seconds -= 1
        if self.countdown_seconds <= 0:
            self.timer_lbl.set_text("Shutting down now...")
            self.action_shutdown()
            return False
        
        self.update_timer_label()
        return True

    def on_bg_clicked(self, widget, event):
        # Only click directly on the background eventbox triggers cancel
        if event.window == widget.get_window():
            self.action_cancel()
            return True
        return False

    def on_key_press(self, widget, event):
        keyval = event.keyval
        keyname = Gdk.keyval_name(keyval)

        if keyname == "Escape" or keyname in ["c", "C"]:
            self.action_cancel()
            return True
        elif keyname in ["s", "S"]:
            self.action_shutdown()
            return True
        elif keyname in ["r", "R"]:
            self.action_reboot()
            return True
        elif keyname in ["l", "L"]:
            self.action_lock()
            return True
        elif keyname in ["e", "E", "o", "O"]:
            self.action_logout()
            return True
        elif keyname in ["h", "H"]:
            self.action_hibernate()
            return True

        return False

    # Actions Callbacks
    def action_shutdown(self):
        self.stop_timer()
        subprocess.run(["systemctl", "poweroff"])
        Gtk.main_quit()

    def action_reboot(self):
        self.stop_timer()
        subprocess.run(["systemctl", "reboot"])
        Gtk.main_quit()

    def action_lock(self):
        self.stop_timer()
        # Lock in background and close menu
        subprocess.Popen(["hyprlock"])
        Gtk.main_quit()

    def action_logout(self):
        self.stop_timer()
        subprocess.run(["hyprctl", "dispatch", "exit", "0"])
        Gtk.main_quit()

    def action_hibernate(self):
        self.stop_timer()
        subprocess.run(["systemctl", "hibernate"])
        Gtk.main_quit()

    def action_cancel(self):
        self.stop_timer()
        Gtk.main_quit()

def main():
    # Load custom styles
    style_provider = Gtk.CssProvider()
    style_provider.load_from_data(CSS_TEMPLATE.encode('utf-8'))
    Gtk.StyleContext.add_provider_for_screen(
        Gdk.Screen.get_default(),
        style_provider,
        Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
    )

    win = PowerMenuWindow()
    win.show_all()
    
    # Run GTK main loop
    Gtk.main()

if __name__ == '__main__':
    main()
