#!/usr/bin/env python3
"""
Hyprland Bluetooth Notification-Only Pairing Agent
Displays pairing / authorization requests exclusively as notifications in the notification area.
Clicking the notification immediately authorizes, pairs, trusts the device, and hides the notification.
"""

import sys
import subprocess
import dbus
import dbus.service
import dbus.mainloop.glib
from gi.repository import GLib

AGENT_PATH = "/org/bluez/hyprland_agent"
BUS_NAME = "org.bluez"
AGENT_INTERFACE = "org.bluez.Agent1"
AGENT_MANAGER_INTERFACE = "org.bluez.AgentManager1"

def get_device_info(bus, device_path):
    try:
        dev_obj = bus.get_object(BUS_NAME, device_path)
        dev_props = dbus.Interface(dev_obj, "org.freedesktop.DBus.Properties")
        name = str(dev_props.Get("org.bluez.Device1", "Alias"))
        mac = str(dev_props.Get("org.bluez.Device1", "Address"))
        return name, mac
    except Exception:
        return "Unknown Device", str(device_path)

def set_device_trusted(bus, device_path):
    try:
        dev_obj = bus.get_object(BUS_NAME, device_path)
        dev_props = dbus.Interface(dev_obj, "org.freedesktop.DBus.Properties")
        dev_props.Set("org.bluez.Device1", "Trusted", dbus.Boolean(True))
    except Exception as e:
        print(f"Error setting trusted: {e}", file=sys.stderr)

def prompt_user_notification(title, body):
    """
    Shows a notification in the notification area with interactive action.
    Returns True if user clicks the notification / Allow, False otherwise.
    """
    cmd = [
        "notify-send",
        "-a", "Bluetooth",
        "-u", "critical",
        "-t", "45000",
        "-i", "bluetooth",
        "-A", "default=Allow & Connect",
        "-A", "allow=Allow & Connect",
        "-A", "deny=Deny",
        title,
        body
    ]
    try:
        proc = subprocess.run(cmd, capture_output=True, text=True, timeout=45)
        choice = proc.stdout.strip().lower()
        if choice in ("default", "allow", "0", "1"):
            return True
        return False
    except (subprocess.TimeoutExpired, Exception) as e:
        print(f"Notification prompt error or timeout: {e}", file=sys.stderr)
        return False

def show_success_notification(dev_name):
    try:
        subprocess.run([
            "notify-send",
            "-a", "Bluetooth",
            "-u", "normal",
            "-t", "3500",
            "-i", "bluetooth",
            "󰄬 Connected & Paired",
            f"Successfully authorized {dev_name}"
        ], check=False)
    except Exception:
        pass

class BlueZNotificationAgent(dbus.service.Object):
    def __init__(self, bus, path):
        super().__init__(bus, path)
        self.bus = bus

    @dbus.service.method(AGENT_INTERFACE, in_signature="", out_signature="")
    def Release(self):
        print("Agent released")

    @dbus.service.method(AGENT_INTERFACE, in_signature="os", out_signature="")
    def AuthorizeService(self, device, uuid):
        dev_name, mac = get_device_info(self.bus, device)
        print(f"AuthorizeService request: {dev_name} ({mac})")

        title = f"Bluetooth Connection: {dev_name}"
        body = f"Device: {mac}\n󰌑 Left-click to Allow & Connect"

        if prompt_user_notification(title, body):
            set_device_trusted(self.bus, device)
            show_success_notification(dev_name)
            return
        raise dbus.exceptions.DBusException("org.bluez.Error.Rejected", "Connection rejected by user")

    @dbus.service.method(AGENT_INTERFACE, in_signature="o", out_signature="")
    def RequestAuthorization(self, device):
        dev_name, mac = get_device_info(self.bus, device)
        print(f"RequestAuthorization request: {dev_name} ({mac})")

        title = f"Pairing Request: {dev_name}"
        body = f"Device: {mac}\n󰌑 Left-click to Allow & Connect"

        if prompt_user_notification(title, body):
            set_device_trusted(self.bus, device)
            show_success_notification(dev_name)
            return
        raise dbus.exceptions.DBusException("org.bluez.Error.Rejected", "Pairing rejected by user")

    @dbus.service.method(AGENT_INTERFACE, in_signature="ou", out_signature="")
    def RequestConfirmation(self, device, passkey):
        dev_name, mac = get_device_info(self.bus, device)
        print(f"RequestConfirmation request: {dev_name} ({mac}) - Passkey: {passkey}")

        title = f"Pairing Request: {dev_name}"
        body = f"Passkey: {passkey:06d}\n󰌑 Left-click to Confirm & Pair"

        if prompt_user_notification(title, body):
            set_device_trusted(self.bus, device)
            show_success_notification(dev_name)
            return
        raise dbus.exceptions.DBusException("org.bluez.Error.Rejected", "Passkey confirmation rejected")

    @dbus.service.method(AGENT_INTERFACE, in_signature="o", out_signature="u")
    def RequestPasskey(self, device):
        dev_name, mac = get_device_info(self.bus, device)
        print(f"RequestPasskey: {dev_name} ({mac})")
        return dbus.UInt32(0)

    @dbus.service.method(AGENT_INTERFACE, in_signature="ouq", out_signature="")
    def DisplayPasskey(self, device, passkey, entered):
        pass

    @dbus.service.method(AGENT_INTERFACE, in_signature="os", out_signature="")
    def DisplayPinCode(self, device, pincode):
        pass

    @dbus.service.method(AGENT_INTERFACE, in_signature="o", out_signature="s")
    def RequestPinCode(self, device):
        return "0000"

    @dbus.service.method(AGENT_INTERFACE, in_signature="", out_signature="")
    def Cancel(self):
        print("Agent request cancelled")

def main():
    dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)
    bus = dbus.SystemBus()
    agent = BlueZNotificationAgent(bus, AGENT_PATH)

    try:
        manager_obj = bus.get_object(BUS_NAME, "/org/bluez")
        manager = dbus.Interface(manager_obj, AGENT_MANAGER_INTERFACE)
        manager.RegisterAgent(AGENT_PATH, "KeyboardDisplay")
        manager.RequestDefaultAgent(AGENT_PATH)
        print("Hyprland Bluetooth Notification Agent active.")
    except Exception as e:
        print(f"Failed to register notification agent: {e}", file=sys.stderr)
        sys.exit(1)

    loop = GLib.MainLoop()
    try:
        loop.run()
    except KeyboardInterrupt:
        pass

if __name__ == '__main__':
    main()
