#!/bin/bash

cd ~
sudo apt update
sudo apt install -y python-is-python3 git pip python3-venv libjpeg libpng

# Clblast build and install

sudo apt update
sudo apt install -y opencl-headers ocl-icd-dev ocl-icd-opencl-dev cmake 

git clone https://github.com/CNugteren/CLBlast.git
#mkdir CLBlast/build
#cd CLBlast/build
#cmake .. -DBUILD_SHARED_LIBS=OFF -DTUNERS=OFF
#cmake --build . --config Release
#sudo cmake --install . --prefix /usr/local

mkdir build
cd build
cmake ..
make
sudo make install  # (optional)

cd ~

# Build llama.cpp
# Left because getting this working is the key to getting oobabooga working.
# cd ~

#git clone https://github.com/ggerganov/llama.cpp.git
#cd llama.cpp
# Build with clblast
#mkdir build
#cd build
#cmake .. -DLLAMA_CLBLAST=ON -DCLBlast_DIR=/usr/local
#cmake --build . --config Release

# Clone Oobabooga
git clone https://github.com/oobabooga/text-generation-webui.git

# Clone the intel arc oobabooga install scripts
git clone https://github.com/kcyarn/oobabooga_intel_arc.git

cp oobabooga_intel_arc/install_arc.sh text-generation-webui

cp oobabooga_intel_arc/run_arc.sh text-generation-webui

cd text-generation-webui

# Run the install arc script.
./install_arc.sh

# clinfo -l
# cd ~/text-generation-webui
# nano run_arc.sh
# change the platform number to yours
# You're looking for a device like Intel(R) Graphics [0x56a0]
# Add a # in front of export GGML_OPENCL_DEVICE= to comment it out.
# Make any changes needed. The oneapi source was already added to bash in step 2.
# ctrl + x then y to save an close
# ./run_arc.sh