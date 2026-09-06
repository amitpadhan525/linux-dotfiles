## Linux dotfiles - simple setup

<div align="center">

[![Download Latest Release](https://img.shields.io/github/v/release/amitpadhan525/linux-dotfiles?color=00D26A&label=Download%20Latest%20Zip&logo=github&style=for-the-badge)](https://github.com/amitpadhan525/linux-dotfiles/releases/latest/download/linux-dotfiles.zip)
[![Release Notes](https://img.shields.io/badge/Release-Notes-blue?style=for-the-badge&logo=github)](https://github.com/amitpadhan525/linux-dotfiles/releases/latest)

</div>

This repo has my dotfiles and simple scripts for Hyprland (Wayland). I use it on Arch Linux.

I wrote this so I can set up my desktop fast on a new system. You can use it too, but be careful and read the steps.

## What is here
- `hyprland/` - all configs for Hyprland, Waybar, rofi, kitty, and other apps
- `install.sh` - script to install and link the configs
- `update.sh` - script to update configs from the repo
- `copy.sh` - helper to copy configs to this repo from your machine
- `RESOURCES.md` - list of packages and other notes

## Quick install (basic)
1. Clone the repo:

```bash
git clone https://github.com/amitpadhan525/linux-dotfiles.git
cd linux-dotfiles
```

2. Run the installer (it may ask for sudo):

```bash
chmod +x install.sh
./install.sh
```

The script will try to back up your current configs before changing them. If you are not sure, take your own backup first.

## Quick update

To update your local configs from this repo:

```bash
chmod +x update.sh
./update.sh
```

## What to customize
- Edit files in `hyprland/hypr/conf/` for display, keybindings, and rules.
- Edit `hyprland/waybar/config` and `hyprland/waybar/style.css` for the bar.
- Put wallpapers in `hyprland/wallpapers/`.

## Notes and tips
- The scripts use `rsync` and `git`, so make sure those are installed.
- If you use other desktop files, check the install script before running.
- For safety, use `--dry-run` options if available to test changes.

## License
This project uses the MIT License. See `LICENSE` for details.

---

Made by Amit. Simple and to the point.
