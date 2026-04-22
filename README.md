<div align="center">
  <img src="https://github.com/amitpadhan525/linux-dotfiles/raw/main/assets/banner.png" alt="Hyprland Logo" width="100%">
  
  # 🌌 Astraeus Hyprland
  **A high-performance, aesthetic, and modular Wayland environment for Arch Linux.**

  [![Hyprland](https://img.shields.io/badge/WM-Hyprland-8839ef?style=for-the-badge&logo=archlinux&logoColor=white)](https://hyprland.org)
  [![Waybar](https://img.shields.io/badge/Bar-Waybar-40a02b?style=for-the-badge&logo=linux&logoColor=white)](https://github.com/Alexays/Waybar)
  [![Rofi](https://img.shields.io/badge/Launcher-Rofi-df8e1d?style=for-the-badge&logo=linux&logoColor=white)](https://github.com/davatorium/rofi)
  [![Kitty](https://img.shields.io/badge/Terminal-Kitty-d20f39?style=for-the-badge&logo=kitty&logoColor=white)](https://sw.kovidgoyal.net/kitty/)
</div>

---

## 🌟 Vision
Welcome to **Astraeus**, a meticulously crafted dotfiles repository designed for users who demand both **extreme performance** and **premium aesthetics**. This isn't just a configuration; it's a fully integrated ecosystem built on top of Arch Linux and Hyprland.

- **🎨 Aesthetic Excellence**: Hand-picked color palettes and glassmorphic UI elements.
- **⚡ Blazing Performance**: Minimal background overhead and GPU-accelerated components.
- **🛠️ Modular Architecture**: Easy to customize and extend without breaking the core system.
- **⌨️ Keyboard Centric**: Navigate your entire workflow without lifting a finger from the home row.

---

## ✨ Key Enhancements

### 🛡️ Smart System Daemons
- **🔋 Battery Sentinel**: Intelligent monitoring with critical alerts at 20% and 10%.
- **🌙 Night Shift**: native blue light filtering via `hyprsunset` (`Super + N`).
- **🔐 Vault Persistence**: Seamless session management through `gnome-keyring` and `polkit`.

### 🚀 Custom Workflow Powerups
- **📸 Precision Capture**: `Super + S` triggers a region selector with a name prompt—no more messy filenames.
- **🌐 Network Pulse**: A sleek Rofi-based Wi-Fi manager integrated directly into Waybar.
- **📊 Live Telemetry**: Real-time tracking of CPU, GPU (AMD), VRAM, and RAM with per-module deep-dives.

---

## ⌨️ Essential Grimoire (Keybindings)

| Binding | Action | Detail |
| :--- | :--- | :--- |
| `Super + Enter` | **Kitty** | GPU Accelerated Terminal |
| `Super + D` | **Launcher** | Rofi Application Runner |
| `Super + E` | **Files** | Thunar File Manager |
| `Super + S` | **Snap** | Named Region Screenshot |
| `Super + N` | **Night** | Toggle Blue Light Filter |
| `Super + L` | **Lock** | Secure System Lock |
| `Super + Q` | **Close** | Terminate Active Window |
| `Super + F` | **Float** | Toggle Floating State |
| `Super + [1-9]` | **Switch** | Jump to Workspace |

---

## 🛠️ Quick Start

### 1. Prerequisites
Ensure you are on a fresh or updated Arch Linux installation.

```bash
sudo pacman -Syu --noconfirm base-devel git
```

### 2. Deployment
Clone the repository and run the automated installer. It will handle dependencies, AUR packages, and configuration links.

```bash
git clone https://github.com/amitpadhan525/linux-dotfiles.git
cd linux-dotfiles
chmod +x install.sh
./install.sh
```

---

## 📂 Architecture

```text
.
├── hyprland/
│   ├── hypr/                 # Core logic & rules
│   │   ├── conf/             # Modular split configs
│   │   └── scripts/          # Workflow automation
│   ├── waybar/               # Aesthetic status engine
│   ├── rofi/                 # Application & menu UIs
│   └── kitty/                # Terminal environment
├── RESOURCES.md              # Dependency deep-dive
└── install.sh                # Main orchestration script
```

---

<div align="center">
  <p>Made with ❤️ by <a href="https://github.com/amitpadhan525">Amit Padhan</a></p>
</div>
