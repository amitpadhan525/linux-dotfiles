#!/usr/bin/env python3
import os
import sys
import time
import subprocess
import fcntl

# Acquire lockfile to prevent duplicate instances
lock_fd = open("/tmp/device-notifier.lock", "w")
try:
    fcntl.flock(lock_fd, fcntl.LOCK_EX | fcntl.LOCK_NB)
except IOError:
    # Exit silently if another instance is already running
    sys.exit(0)

# Redirect stdout and stderr to a log file for troubleshooting
log_path = "/home/amit/.config/hypr/logs/device-notifier.log"
try:
    os.makedirs(os.path.dirname(log_path), exist_ok=True)
    log_file = open(log_path, "a", buffering=1)
    os.dup2(log_file.fileno(), sys.stdout.fileno())
    os.dup2(log_file.fileno(), sys.stderr.fileno())
except Exception as e:
    pass

print(f"[{time.strftime('%Y-%m-%d %H:%M:%S')}] device-notifier started. Environment: PATH={os.environ.get('PATH')}, DBUS_SESSION_BUS_ADDRESS={os.environ.get('DBUS_SESSION_BUS_ADDRESS')}")


def find_ac_supply():
    base = "/sys/class/power_supply"
    if os.path.exists(base):
        for name in os.listdir(base):
            if name.startswith("AC") or name.startswith("ADP") or "charger" in name.lower():
                online_path = os.path.join(base, name, "online")
                if os.path.exists(online_path):
                    return name, online_path
    return None, None

ac_name, ac_path = find_ac_supply()
last_power_online = None

def get_initial_power_state():
    global last_power_online
    if ac_path:
        try:
            with open(ac_path, "r") as f:
                last_power_online = f.read().strip()
        except Exception as e:
            print(f"Error reading initial power supply state: {e}", file=sys.stderr)

def decode_udev_str(s):
    if not s:
        return ""
    try:
        # Decode udev-escaped characters (like \x20 for space)
        return s.encode('utf-8').decode('unicode_escape')
    except Exception:
        return s


def notify(title, message, icon):
    try:
        # Use Dunst/notify-send
        subprocess.run(["notify-send", "-a", "System Monitor", "-i", icon, title, message])
    except Exception as e:
        print(f"Error sending notification: {e}", file=sys.stderr)

def handle_event(props):
    global last_power_online
    subsystem = props.get("SUBSYSTEM")
    action = props.get("ACTION")
    
    if subsystem == "usb":
        devtype = props.get("DEVTYPE")
        if devtype == "usb_device" and action in ("add", "remove"):
            vendor = props.get("ID_VENDOR_FROM_DATABASE") or props.get("ID_VENDOR") or ""
            model = props.get("ID_MODEL_FROM_DATABASE") or props.get("ID_MODEL") or ""
            
            vendor = decode_udev_str(vendor).strip()
            model = decode_udev_str(model).strip()
            
            if not vendor and not model:
                product = props.get("PRODUCT", "")
                name = f"USB Device ({product})"
            else:
                name = f"{vendor} {model}".strip()
                if not name:
                    name = "Unknown USB Device"
            
            if action == "add":
                notify("USB Device Connected", name, "drive-removable-media")
            elif action == "remove":
                notify("USB Device Disconnected", name, "drive-removable-media")
                
    elif subsystem == "power_supply":
        supply_name = props.get("POWER_SUPPLY_NAME")
        if supply_name == ac_name or (supply_name and ("AC" in supply_name or "ADP" in supply_name)):
            online = props.get("POWER_SUPPLY_ONLINE")
            if online is not None and online != last_power_online:
                last_power_online = online
                if online == "1":
                    notify("Charger Connected", "AC adapter plugged in", "ac-adapter")
                elif online == "0":
                    notify("Charger Disconnected", "Running on battery power", "battery")

def parse_udev_events():
    cmd = [
        "udevadm", "monitor", "--udev", "--property",
        "--subsystem-match=usb",
        "--subsystem-match=power_supply"
    ]
    
    process = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True)
    properties = {}
    
    for line in iter(process.stdout.readline, ''):
        line = line.strip()
        if not line:
            if properties:
                handle_event(properties)
                properties = {}
            continue
        
        if line.startswith("UDEV "):
            if properties:
                handle_event(properties)
                properties = {}
            continue
            
        if "=" in line:
            key, val = line.split("=", 1)
            properties[key] = val
            
    # Process any remaining properties if stdout closes
    if properties:
        handle_event(properties)

def main():
    get_initial_power_state()
    
    # Simple rate-limiting for startup to avoid spamming multiple notifications if any events were queued
    time.sleep(1)
    
    while True:
        try:
            parse_udev_events()
        except KeyboardInterrupt:
            break
        except Exception as e:
            print(f"Error in monitor loop: {e}", file=sys.stderr)
            time.sleep(2)

if __name__ == "__main__":
    main()
