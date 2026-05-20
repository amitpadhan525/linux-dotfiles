#!/usr/bin/env python3
import sys
import os
import signal
import subprocess
import gi
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk, GLib, Gdk

class ScreenRecorderPopup(Gtk.Window):
    def __init__(self, saved_path):
        self.saved_path = saved_path
        self.pid_file = "/tmp/wf-recorder.pid"
        self.path_file = "/tmp/wf-recorder.path"
        
        # Initialize window with premium properties
        GLib.set_prgname("screen-recorder-popup")
        GLib.set_application_name("Screen Recorder Control")
        
        super().__init__(title="Screen Recorder Control")
        
        # Set window name/class for Hyprland rules
        self.set_name("screen-recorder-popup")
        self.set_wmclass("screen-recorder-popup", "screen-recorder-popup")
        self.set_keep_above(True)
        self.set_decorated(False)
        self.set_resizable(False)
        self.set_border_width(8)
        self.set_type_hint(Gdk.WindowTypeHint.UTILITY)
        
        # Enable visual transparency if supported
        screen = self.get_screen()
        visual = screen.get_rgba_visual()
        if visual and screen.is_composited():
            self.set_visual(visual)
            
        # Variables
        self.seconds = 0
        self.dot_visible = True
        
        # Main layout
        self.box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=10)
        self.add(self.box)
        
        # Pulsing Red Dot (Unicode character)
        self.dot_label = Gtk.Label(label="●")
        self.dot_label.get_style_context().add_class("rec-dot")
        self.box.pack_start(self.dot_label, False, False, 0)
        
        # Timer label
        self.timer_label = Gtk.Label(label="00:00")
        self.timer_label.get_style_context().add_class("timer-label")
        self.box.pack_start(self.timer_label, True, True, 0)
        
        # Stop Button
        self.stop_btn = Gtk.Button(label="⏹ Stop")
        self.stop_btn.connect("clicked", self.on_stop_clicked)
        self.stop_btn.get_style_context().add_class("stop-btn")
        self.box.pack_start(self.stop_btn, False, False, 0)
        
        # Style with CSS
        self.apply_css()
        
        # Start timer tick
        GLib.timeout_add_seconds(1, self.tick)
        
        # Monitor wf-recorder PID to close automatically if wf-recorder dies
        GLib.timeout_add(500, self.monitor_wf_recorder)
        
        self.show_all()
        
    def apply_css(self):
        css_provider = Gtk.CssProvider()
        css = b"""
        window {
            background-color: rgba(20, 20, 20, 0.85);
            border-radius: 10px;
            border: 1px solid rgba(255, 255, 255, 0.15);
        }
        .rec-dot {
            color: #ff3b30;
            font-size: 16px;
        }
        .timer-label {
            color: #ffffff;
            font-size: 15px;
            font-weight: bold;
            font-family: 'Outfit', 'Inter', 'sans-serif';
            margin-right: 5px;
        }
        .stop-btn {
            background-image: none;
            background-color: #ff3b30;
            color: #ffffff;
            font-size: 13px;
            font-weight: bold;
            border-radius: 6px;
            padding: 4px 10px;
            border: none;
            text-shadow: none;
            box-shadow: none;
        }
        .stop-btn:hover {
            background-color: #ff453a;
        }
        """
        css_provider.load_from_data(css)
        Gtk.StyleContext.add_provider_for_screen(
            Gdk.Screen.get_default(),
            css_provider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        )
        
    def tick(self):
        # Increment seconds
        self.seconds += 1
        mins = self.seconds // 60
        secs = self.seconds % 60
        self.timer_label.set_text(f"{mins:02d}:{secs:02d}")
        
        # Pulse the red dot
        self.dot_visible = not self.dot_visible
        if self.dot_visible:
            self.dot_label.set_text("●")
        else:
            self.dot_label.set_text(" ")
            
        return True
        
    def monitor_wf_recorder(self):
        # Check if wf-recorder is still running
        try:
            res = subprocess.run(["pgrep", "-u", str(os.getuid()), "-x", "wf-recorder"], stdout=subprocess.PIPE)
            if res.returncode != 0:
                # wf-recorder has stopped, close and notify
                self.cleanup_and_notify()
                Gtk.main_quit()
                return False
        except Exception:
            pass
        return True
        
    def on_stop_clicked(self, widget):
        # Stop wf-recorder
        try:
            res = subprocess.run(["pgrep", "-u", str(os.getuid()), "-x", "wf-recorder"], stdout=subprocess.PIPE)
            if res.returncode == 0:
                pids = res.stdout.decode().strip().split()
                for pid in pids:
                    os.kill(int(pid), signal.SIGINT)
        except Exception as e:
            print(f"Error killing wf-recorder: {e}")
            
        self.cleanup_and_notify()
        Gtk.main_quit()
        
    def cleanup_and_notify(self):
        # Clean up files
        for f in [self.pid_file, self.path_file]:
            if os.path.exists(f):
                try:
                    os.remove(f)
                except OSError:
                    pass
                    
        # Send notification
        try:
            subprocess.run(["notify-send", "-t", "5000", "Recording Saved", f"Video saved to:\n{self.saved_path}"])
        except Exception:
            pass

if __name__ == "__main__":
    path = sys.argv[1] if len(sys.argv) > 1 else "~/Videos/Recordings"
    
    # Handle termination signals cleanly
    def signal_handler(sig, frame):
        Gtk.main_quit()
    signal.signal(signal.SIGINT, signal_handler)
    signal.signal(signal.SIGTERM, signal_handler)
    
    app = ScreenRecorderPopup(path)
    Gtk.main()
