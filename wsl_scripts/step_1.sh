#!/bin/bash
# This step is all about verifying WSL is accessing the GPU and not the CPU.
# Do not install Ubuntu from the microsoft store!
# If you have installed it from the microsoft store, uninstall it first.
# wsl --unregister Ubuntu-22.04
# Set a default distro in wsl2.
# wsl --list --online
# wsl --install -d Ubuntu-22.04
# wsl --setdefault Ubuntu-22.04
# wsl -t Ubuntu-22.04
# wsl --shutdown
# wsl -d Ubuntu-22.04

# After finishing the above in powershell, you shouldn't get anymore <3>WSL (8) ERROR: CreateProcessParseCommon errors.
# Whenever you see this, terminate ubuntu, shutdown wsl, and then restart ubuntu.

# Start by enabling uhd graphics in the device manager along with the video card. May not be necessary if you only have the card.
# Clean install wsl

sudo apt update

sudo apt upgrade -y

sudo add-apt-repository ppa:oibaf/graphics-drivers
sudo apt update
sudo apt upgrade -y

sudo apt install -y vainfo

sudo apt install -y mesa-va-drivers

# Run vainfo --display drm --device /dev/dri/card0
# Output is the UHD Graphics 770

# One of the simpler ways to test whether its using the GPU.
# Also grabs a lot of the dependencies needed later.
sudo apt install -y ffmpeg
sudo apt install -y gstreamer1.0-plugins-bad gstreamer1.0-tools gstreamer1.0-vaapi

cd ~
# Add environment variables to bashrc
# Check if the line already exists in ~/.bashrc
if ! grep -q "export LIBVA_DRIVER_NAME=d3d12" ~/.bashrc; then
    # If it doesn't exist, append the line to the end of ~/.bashrc
    echo "export LIBVA_DRIVER_NAME=d3d12" >> ~/.bashrc
fi

#if ! grep -q "export LIBGL_DRIVERS_PATH=/usr/lib/x86_64-linux-gnu/dri" ~/.bashrc; then
    # If it doesn't exist, append the line to the end of ~/.bashrc
#    echo "export LIBGL_DRIVERS_PATH=/usr/lib/x86_64-linux-gnu/dri" >> ~/.bashrc
#fi

#if ! grep -q "export GALLIUM_DRIVER=d3d12" ~/.bashrc; then
    # If it doesn't exist, append the line to the end of ~/.bashrc
#    echo "export GALLIUM_DRIVER=d3d12" >> ~/.bashrc
#fi

sudo shutdown now

# wsl -t Ubuntu-22.04
# wsl -d Ubuntu-22.04 to start the machine
# Test with 
# cd ~
# vainfo --display drm --device /dev/dri/card0
# You should see your gpu listed.
# If not, it's likely related to CreateProcessParseCommon error.
# Right now, the below won't do anything real yet. Hang on to it for later.
# gst-launch-1.0 -v videotestsrc num-buffers=250 ! video/x-raw,width=1920,height=1200 ! vaapipostproc ! vaapih264enc ! filesink location=~/wsl_test.h264