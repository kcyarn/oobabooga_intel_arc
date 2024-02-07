#!/bin/bash
# Run vainfo --display drm --device /dev/dri/card0
# If it shows an integrated GPU instead of the Arc graphics card, disable integrated graphics.
# For example, Device manager > Display adapters right click to disable uhd graphics (integrated graphics)
# Run vainfo --display drm --device /dev/dri/card0 again.
# Now it sees (Intel(R) Arc(TM) A770 Graphics)

# Begin installing intel drivers.
# WSL2's available kernels do not match any of the kernels intel recommends for their gpu.
# Compiling a new kernel may be necessary for stability.

cd ~

wget -qO - https://repositories.intel.com/graphics/intel-graphics.key |
  sudo gpg --dearmor --output /usr/share/keyrings/intel-graphics.gpg
echo 'deb [arch=amd64,i386 signed-by=/usr/share/keyrings/intel-graphics.gpg] https://repositories.intel.com/graphics/ubuntu jammy arc' | \
  sudo tee  /etc/apt/sources.list.d/intel.gpu.jammy.list

sudo apt update

sudo apt upgrade -y

sudo adduser ${USER} render

sudo usermod -a -G video ${USER}

# Step through these. Tested as I went with clinfo and vainfo --display...
# If clinfo returns nothing, something's gone wrong.
# Works
sudo apt-get install -y \
  intel-opencl-icd intel-level-zero-gpu level-zero clinfo
# Works
sudo apt install -y \
  intel-media-va-driver-non-free libmfx1 libmfxgen1 libvpl2
# Works
sudo apt install -y \
  libegl-mesa0 libegl1-mesa libegl1-mesa-dev libgbm1 libgl1-mesa-dev libgl1-mesa-dri
# Works
sudo apt install -y \
  libglapi-mesa libgles2-mesa-dev libglx-mesa0 libigdgmm12 libxatracker2 mesa-va-drivers
# Works
sudo apt install -y \
  mesa-vdpau-drivers mesa-vulkan-drivers va-driver-all

# Now install x11-apps

sudo apt-get install x11-apps -y

# xeyes or xclock to verify it's running.
# This isn't strictly necessary, but it's nice to see the GPU is displaying form WSL.

# Install oneAPI

wget -O- https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB \ | gpg --dearmor | sudo tee /usr/share/keyrings/oneapi-archive-keyring.gpg > /dev/null

echo "deb [signed-by=/usr/share/keyrings/oneapi-archive-keyring.gpg] https://apt.repos.intel.com/oneapi all main" | sudo tee /etc/apt/sources.list.d/oneAPI.list

sudo apt update

sudo apt upgrade -y

sudo apt install -y intel-basekit

# Add environment variable for oneapi
# Check if the line already exists in ~/.bashrc
if ! grep -q "source /opt/intel/oneapi/setvars.sh" ~/.bashrc; then
    # If it doesn't exist, append the line to the end of ~/.bashrc
    echo "source /opt/intel/oneapi/setvars.sh" >> ~/.bashrc
fi

. ~/.bashrc

# Restart ubuntu
# wsl -t Ubuntu-22.04