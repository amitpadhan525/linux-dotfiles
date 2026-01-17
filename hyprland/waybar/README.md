# Hyprland Waybar Configuration

A clean, modern, and minimalist status bar configuration for [Waybar](https://github.com/Alexays/Waybar), designed for the **Hyprland** compositor.

## 🎨 Features

- **Minimalist Design**: Dark themed background with semi-transparent, rounded modules.
- **System Monitoring**: Real-time stats for CPU, RAM, and Disk usage.
- **Connectivity**: Network status (WiFi/Ethernet) and disconnected state.
- **Media & Power**: PulseAudio volume control and Battery level monitoring with visual icons.
- **Tray Support**: integrated system tray for background applications.

## 🔧 Modules

The configuration includes the following modules (from left to right):

| Position | Modules | Description |
|----------|---------|-------------|
| **Left** | `cpu`, `memory`, `disk` | System resource usage percentages. |
| **Center** | `clock` | Current date and time (`Day Date Month Time`). |
| **Right** | `network`, `pulseaudio`, `battery`, `tray` | Connection status, volume, battery, and system tray. |

## 📦 Dependencies

- **[Waybar](https://github.com/Alexays/Waybar)**: The status bar application itself.
- **[Font Awesome](https://fontawesome.com/)** (or a Nerd Font): Required for the icons (, , , etc.) to display correctly.

## 🚀 Installation

1.  **Backup** your existing configuration:
    ```bash
    cp -r ~/.config/waybar ~/.config/waybar.bak
    ```

2.  **Copy** the files to your Waybar configuration directory:
    ```bash
    # Assuming you are in the directory containing this README
    cp config ~/.config/waybar/config
    cp style.css ~/.config/waybar/style.css
    # Optional: Copy scripts if you intend to use custom modules later
    cp -r scripts/ ~/.config/waybar/
    ```

3.  **Reload** Waybar:
    If Waybar is already running, changes usually apply automatically. If not, kill and restart it:
    ```bash
    killall waybar
    waybar &
    ```

## 🛠️ Customization

-   **Colors**: Edit `style.css` to change the background colors to match your wallpaper or theme.
-   **Modules**: Modify `config` to add/remove modules or change their order.
-   **Scripts**: A `scripts/` directory is included with custom shell scripts (`battery_info.sh`, `cpu_mem.sh`, etc.) if you wish to extend functionality with `custom` modules in the future.
