#!/bin/bash
# Script to set up and run Tiny10 in Google Cloud Shell using QEMU
# Improved with error handling and verification

set -e  # Exit immediately if a command fails

echo "Setting up environment for Tiny10 in Google Cloud Shell..."

# Install required packages with verification
echo "Installing required packages..."
sudo apt-get update

# Install packages one by one with verification
echo "Installing QEMU..."
sudo apt-get install -y qemu-system-x86
if ! command -v qemu-system-x86_64 &> /dev/null; then
    echo "Error: qemu-system-x86_64 installation failed. Trying alternative package name..."
    sudo apt-get install -y qemu-kvm
fi

echo "Installing QEMU utilities..."
sudo apt-get install -y qemu-utils
if ! command -v qemu-img &> /dev/null; then
    echo "Error: qemu-img installation failed."
    exit 1
fi

echo "Installing wget..."
sudo apt-get install -y wget

echo "Installing noVNC and websockify..."
sudo apt-get install -y novnc websockify
if ! command -v websockify &> /dev/null; then
    echo "Error: websockify installation failed. Trying Python pip install..."
    sudo apt-get install -y python3-pip
    pip3 install websockify
fi

# Verify all required commands are available
for cmd in qemu-system-x86_64 qemu-img wget websockify; do
    if ! command -v $cmd &> /dev/null; then
        echo "Error: Required command '$cmd' is not available after installation attempts."
        echo "Please install it manually or contact cloud shell support."
        exit 1
    fi
done

# Create a working directory
mkdir -p ~/tiny10
cd ~/tiny10

# Check if ISO already exists to avoid redownloading
if [ ! -f "tiny10.iso" ]; then
    echo "Downloading Tiny10 ISO..."
    wget -O tiny10.iso "https://archive.org/download/tiny-10-NTDEV/tiny10%20x86%20beta%202.iso"
else
    echo "Tiny10 ISO already exists, skipping download."
fi

# Create a virtual disk for the installation
echo "Creating virtual disk (10GB)..."
qemu-img create -f qcow2 tiny10.qcow2 10G

# Set up VNC for accessing the VM
echo "Setting up VNC access..."
mkdir -p ~/.vnc

# Start websockify for noVNC
echo "Starting noVNC websocket..."
websockify -D --web=/usr/share/novnc/ 8080 localhost:5901
if [ $? -ne 0 ]; then
    echo "Failed to start websockify. Trying alternative method..."
    python3 -m websockify -D --web=/usr/share/novnc/ 8080 localhost:5901
fi

# Start QEMU with the Tiny10 ISO
echo "Starting QEMU with Tiny10 ISO..."
echo "Access the VM through the Web Preview on port 8080"

# Run QEMU with the Tiny10 ISO
qemu-system-x86_64 -m 2G -smp 2 -hda tiny10.qcow2 -cdrom tiny10.iso -boot d -vnc :1 -accel tcg

echo "When you want to restart the VM later without reinstalling, use:"
echo "cd ~/tiny10 && qemu-system-x86_64 -m 2G -smp 2 -hda tiny10.qcow2 -vnc :1 -accel tcg"
