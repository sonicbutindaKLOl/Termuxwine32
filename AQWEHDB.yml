name: Termux Wine ARM32 Installer
description: Automated Wine installer for Termux on ARM 32-bit (armv7) devices with X11 forwarding

on: [push]

jobs:
  generate-installer:
    runs-on: ubuntu-latest
    steps:
      - name: Create Installer Script
        run: |
          cat > termux-wine-arm32-installer.sh << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash

# Termux Wine ARM32 Automated Installer
# This script installs and configures Wine on Termux for ARM 32-bit devices
# with X11 forwarding to Termux:11

echo "======================================================="
echo "  Termux Wine ARM32 Installer with X11 Forwarding"
echo "======================================================="

# Function to check for errors
check_error() {
  if [ $? -ne 0 ]; then
    echo "Error: $1"
    exit 1
  fi
}

# Update and upgrade packages
echo "[1/9] Updating package repositories..."
pkg update -y && pkg upgrade -y
check_error "Failed to update packages"

# Install required dependencies
echo "[2/9] Installing dependencies..."
pkg install -y x11-repo proot proot-distro wget curl xorg-xhost pulseaudio
check_error "Failed to install dependencies"

# Install Termux:X11 if not already installed
echo "[3/9] Setting up X11 environment..."
pkg install -y termux-x11-nightly
check_error "Failed to install Termux:X11"

# Install PulseAudio for sound support
pkg install -y pulseaudio 
check_error "Failed to install PulseAudio"

# Set up PulseAudio configuration
mkdir -p ~/.config/pulse
cat > ~/.config/pulse/default.pa << 'PULSE_EOF'
#!/usr/bin/pulseaudio -nF
load-module module-native-protocol-tcp auth-anonymous=1
load-module module-native-protocol-unix auth-anonymous=1
load-module module-echo-cancel aec_method=webrtc source_name=echocancel sink_name=echocancel1
set-default-source echocancel
set-default-sink echocancel1
PULSE_EOF

# Create setup script for Debian environment
echo "[4/9] Creating setup script for Debian environment..."
mkdir -p ~/debian-wine-setup
cat > ~/debian-wine-setup/setup.sh << 'DEBIAN_EOF'
#!/bin/bash

# Setup Wine in Debian environment
dpkg --add-architecture armhf
apt update && apt upgrade -y
apt install -y wget gnupg software-properties-common apt-transport-https winbind cabextract

# Add Wine repository
wget -nc https://dl.winehq.org/wine-builds/winehq.key
apt-key add winehq.key
echo "deb https://dl.winehq.org/wine-builds/debian/ bullseye main" > /etc/apt/sources.list.d/wine.list
apt update

# Install Wine
apt install -y --install-recommends winehq-stable

# Install winetricks
wget -q https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks -O /usr/local/bin/winetricks
chmod +x /usr/local/bin/winetricks

# Install additional libraries for better compatibility
apt install -y libfreetype6:armhf libpng16-16:armhf libxml2:armhf libglu1-mesa:armhf \
               libasound2-plugins:armhf libjpeg62-turbo:armhf libcups2:armhf libfontconfig1:armhf \
               libgnutls30:armhf libgpg-error0:armhf libpulse0:armhf libsqlite3-0:armhf libxcomposite1:armhf \
               libxcursor1:armhf libxi6:armhf libxrandr2:armhf libxrender1:armhf libxss1:armhf libxtst6:armhf

echo "Wine setup complete in Debian environment!"
DEBIAN_EOF
chmod +x ~/debian-wine-setup/setup.sh

# Set up proot-distro with Debian
echo "[5/9] Installing Debian environment..."
proot-distro install debian
check_error "Failed to install Debian environment"

# Configure Debian environment for Wine
echo "[6/9] Configuring Wine in Debian environment..."
proot-distro login debian -- bash -c "bash /root/debian-wine-setup/setup.sh"
check_error "Failed to configure Wine in Debian"

# Create startup script for Wine with X11 forwarding
echo "[7/9] Creating Wine startup script..."
cat > ~/start-wine.sh << 'WINE_EOF'
#!/data/data/com.termux/files/usr/bin/bash

# Start PulseAudio server if not running
pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" --exit-idle-time=-1
# Load the environment variable for display
export DISPLAY=:1

# Start Termux:X11 in the background
am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity

# Start Wine in Debian environment
echo "Starting Wine with X11 forwarding to Termux:X11..."
proot-distro login debian -- bash -c "export DISPLAY=:1 PULSE_SERVER=127.0.0.1 WINE_PREFIX=~/.wine && wine explorer"

# You can replace the last line with a specific Windows application, for example:
# proot-distro login debian -- bash -c "export DISPLAY=:1 PULSE_SERVER=127.0.0.1 WINE_PREFIX=~/.wine && wine 'C:\\path\\to\\your\\app.exe'"
WINE_EOF
chmod +x ~/start-wine.sh

# Create a helper script for winetricks
echo "[8/9] Creating winetricks helper script..."
cat > ~/run-winetricks.sh << 'WINETRICKS_EOF'
#!/data/data/com.termux/files/usr/bin/bash

export DISPLAY=:1
am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity
proot-distro login debian -- bash -c "export DISPLAY=:1 PULSE_SERVER=127.0.0.1 WINE_PREFIX=~/.wine && winetricks"
WINETRICKS_EOF
chmod +x ~/run-winetricks.sh

# Create .bashrc additions
echo "[9/9] Adding shortcuts to .bashrc..."
cat >> ~/.bashrc << 'BASHRC_EOF'

# Wine shortcuts
alias start-wine="~/start-wine.sh"
alias winetricks="~/run-winetricks.sh"
BASHRC_EOF

echo ""
echo "======================================================="
echo "  Installation Complete!"
echo "======================================================="
echo ""
echo "To start Wine, run:"
echo "  ~/start-wine.sh"
echo ""
echo "To run winetricks, use:"
echo "  ~/run-winetricks.sh"
echo ""
echo "You can also use the shortcuts (after restarting Termux):"
echo "  start-wine"
echo "  winetricks"
echo ""
echo "Make sure you have installed Termux:X11 app from GitHub or F-Droid"
echo "  https://github.com/termux/termux-x11/releases"
echo "  or from F-Droid"
echo ""
echo "For best results, ensure your device supports 32-bit apps"
echo "and has sufficient storage and RAM."
echo "======================================================="
EOF

          chmod +x termux-wine-arm32-installer.sh

      - name: Upload installer
        uses: actions/upload-artifact@v2
        with:
          name: termux-wine-arm32-installer
          path: termux-wine-arm32-installer.sh

      - name: Create README.md
        run: |
          cat > README.md << 'EOF'
# Termux Wine ARM32 Installer

An automated installer script for running Wine on 32-bit ARM (armv7) devices using Termux with X11 forwarding to Termux:X11.

## Installation

### Prerequisites

1. Install [Termux](https://github.com/termux/termux-app) from F-Droid or GitHub
2. Install [Termux:X11](https://github.com/termux/termux-x11/releases) app

### Quick Installation

1. Run the following command in Termux:

```bash
curl -L https://raw.githubusercontent.com/YOUR_USERNAME/termux-wine-arm32/main/termux-wine-arm32-installer.sh -o installer.sh && chmod +x installer.sh && ./installer.sh
```

Replace `YOUR_USERNAME` with your actual GitHub username where you've uploaded this script.

## Usage

After installation, you can use the following commands:

- To start Wine: `start-wine` or `~/start-wine.sh`
- To run winetricks: `winetricks` or `~/run-winetricks.sh`

## Customization

You can modify the `~/start-wine.sh` script to run specific Windows applications instead of the default Wine explorer.

## Notes for ARM 32-bit Devices

- Performance may be limited on ARM devices
- Not all Windows applications will work, especially those requiring 64-bit support
- You may need to use winetricks to install additional dependencies for specific applications

## Troubleshooting

- If you encounter "Bad system call" errors, try running Termux with `ANDROID_DATA=/data/data/com.termux/files ANDROID_ROOT=/system termux-chroot`
- For graphics issues, make sure Termux:X11 is properly installed and running
- For sound issues, try restarting PulseAudio with `pulseaudio --kill && pulseaudio --start`

EOF

      - name: Upload README
        uses: actions/upload-artifact@v2
        with:
          name: termux-wine-arm32-installer
          path: README.md
