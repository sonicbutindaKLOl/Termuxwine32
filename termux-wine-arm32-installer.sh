#!/bin/bash
# Script to set up and run Tiny10 in Google Cloud Shell using QEMU

echo "Setting up environment for Tiny10 in Google Cloud Shell..."

# Install required packages
sudo apt-get update
sudo apt-get install -y qemu-system-x86 qemu-utils wget novnc websockify

# Create a working directory
mkdir -p ~/tiny10
cd ~/tiny10

# Download the Tiny10 ISO
echo "Downloading Tiny10 ISO..."
wget -O tiny10.iso "https://archive.org/download/tiny-10-NTDEV/tiny10%20x86%20beta%202.iso"

# Create a virtual disk for the installation
echo "Creating virtual disk (10GB)..."
qemu-img create -f qcow2 tiny10.qcow2 10G

# Set up VNC for accessing the VM
echo "Setting up VNC access..."
mkdir -p ~/.vnc

# Start websockify for noVNC
echo "Starting noVNC websocket..."
websockify -D --web=/usr/share/novnc/ 8080 localhost:5901

# Start QEMU with the Tiny10 ISO
echo "Starting QEMU with Tiny10 ISO..."
echo "Access the VM through the Web Preview on port 8080"

# Run QEMU with the Tiny10 ISO
qemu-system-x86_64 -m 2G -smp 2 -hda tiny10.qcow2 -cdrom tiny10.iso -boot d -vnc :1 -accel tcg

echo "When you want to restart the VM later without reinstalling, use:"
echo "cd ~/tiny10 && qemu-system-x86_64 -m 2G -smp 2 -hda tiny10.qcow2 -vnc :1 -accel tcg"
