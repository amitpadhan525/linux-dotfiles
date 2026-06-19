#!/usr/bin/env python3
import sys
import os
import time
import subprocess
import json
import threading

# Backlight path
BACKLIGHT_DIR = "/sys/class/backlight/amdgpu_bl1"

def get_brightness():
    try:
        with open(os.path.join(BACKLIGHT_DIR, "brightness"), "r") as f:
            b = int(f.read().strip())
        with open(os.path.join(BACKLIGHT_DIR, "max_brightness"), "r") as f:
            m = int(f.read().strip())
        return int((b / m) * 100)
    except Exception:
        return None

def get_volume_info():
    try:
        vol = int(subprocess.check_output(["pamixer", "--get-volume"], text=True).strip())
        mute = subprocess.check_output(["pamixer", "--get-mute"], text=True).strip() == "true"
        return vol, mute
    except Exception:
        return None, None

def main():
    last_vol, last_mute = get_volume_info()
    last_bright = get_brightness()

    # OSD state variables
    state = "hidden"  # hidden, showing, hiding
    current_text = ""
    active_until = 0.0
    hide_until = 0.0
    lock = threading.Lock()

    def output_json(text, css_class=""):
        res = {"text": text, "class": css_class, "tooltip": text}
        sys.stdout.write(json.dumps(res) + "\n")
        sys.stdout.flush()

    # Start with empty string (completely hidden)
    output_json("")

    # Timer/OSD state machine thread
    def OSD_state_thread():
        nonlocal state, active_until, hide_until, current_text
        while True:
            time.sleep(0.02)
            with lock:
                now = time.time()
                if state == "showing" and now > active_until:
                    # Switch to hiding state and trigger hide class
                    state = "hiding"
                    hide_until = now + 0.35  # 0.35s hide animation duration (slightly longer than CSS 0.3s)
                    output_json(current_text, "hide")
                elif state == "hiding" and now > hide_until:
                    # Completely hide
                    state = "hidden"
                    current_text = ""
                    output_json("")

    threading.Thread(target=OSD_state_thread, daemon=True).start()

    def trigger_osd(text):
        nonlocal state, active_until, current_text
        with lock:
            current_text = text
            state = "showing"
            active_until = time.time() + 1.7  # 1.7s show duration
            output_json(text, "show")

    def volume_listener():
        nonlocal last_vol, last_mute
        try:
            proc = subprocess.Popen(["pactl", "subscribe"], stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True)
            for line in proc.stdout:
                if "sink" in line or "server" in line:
                    vol, mute = get_volume_info()
                    if vol is not None:
                        if vol != last_vol or mute != last_mute:
                            last_vol, last_mute = vol, mute
                            if mute:
                                text = "󰝟 Muted"
                            elif vol == 0:
                                text = "󰝟 0%"
                            elif vol < 30:
                                text = f" {vol}%"
                            else:
                                text = f" {vol}%"
                            trigger_osd(text)
        except Exception:
            pass

    threading.Thread(target=volume_listener, daemon=True).start()

    # Brightness listener loop (polls every 0.05s)
    while True:
        time.sleep(0.05)
        bright = get_brightness()
        if bright is not None and bright != last_bright:
            if last_bright is not None:
                if bright < 30:
                    icon = "󰃞"
                elif bright < 70:
                    icon = "󰃟"
                else:
                    icon = "󰃠"
                text = f"{icon} {bright}%"
                trigger_osd(text)
            last_bright = bright

if __name__ == "__main__":
    main()
