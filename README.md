# retab - Toggle indentation in Micro

## About:
`retab` is a simple Micro plugin for toggling indentation between tabs and spaces.  
It automatically uses the buffer's tabsize and works in both directions: spaces → tabs and tabs → spaces.  
Displays a brief info message in Micro's InfoBar after conversion.  
Compatible with Micro >= 2.0.0.  
Author: Kamil BuriXon Burek, Version: 1.0.0.  

This plugin is useful for developers who want a quick and reliable way to normalize indentation.  
It’s a small, fast, and handy alternative to manually adjusting tabs or spaces.

## Installation:

### Manual installation:
1. Make sure you have Micro >= 2.0.0 installed (command `micro --version`).
2. Navigate to the Micro plugins directory:
```
mkdir -p ~/.config/micro/plug
cd ~/.config/micro/plug
```
3. Download the plugin:
```
wget https://raw.githubusercontent.com/BuriXon-code/micro-retab-plugin/main/retab.lua
```
4. Restart Micro to load the plugin.

### Using Git:
1. Navigate to the Micro plugins directory:
```
mkdir -p ~/.config/micro/plug
cd ~/.config/micro/plug
```
2. Clone the repository:
```
git clone https://github.com/BuriXon-code/micro-retab-plugin.git
```
3. Restart Micro.

### Notes for package managers:
- **Debian/Ubuntu/Termux (pkg/apt)**: make sure `micro` is installed via `apt install micro` or `pkg install micro`.
- **Arch Linux/Manjaro (pacman)**: `sudo pacman -S micro`.
- **Fedora/RHEL (dnf)**: `sudo dnf install micro`.
- **Alpine (apk)**: `sudo apk add micro`.

## Usage:
In Micro (`Ctrl+E`), simply type:
```
retab
```
This will convert leading spaces to tabs or leading tabs to spaces according to your buffer tabsize.  
After completion, a short message appears in Micro's InfoBar indicating what conversion was performed.

## Support
### Contact me:
For any issues, suggestions, or questions, reach out via:

- *Email:* support@burixon.dev
- *Contact form:* [Click here](https://burixon.dev/contact/)
- *Bug reports:* [Click here](https://burixon.dev/bugreport/#Termux-WiFi-map)

### Support me:
If you find this script useful, consider supporting my work by making a donation:

[**Donations**](https://burixon.dev/donate/)

Your contributions help in developing new projects and improving existing tools!
