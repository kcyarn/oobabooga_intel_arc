#!/bin/bash

# Check if the virtual environment already exists
if [[ ! -d "venv" ]]; then
    # Create the virtual environment
    python -m venv venv
fi

# Activate the virtual environment
source venv/bin/activate

# Intel extension for transformers recently added Arc support.
# See https://github.com/intel/intel-extension-for-transformers/blob/main/intel_extension_for_transformers/neural_chat/docs/notebooks/build_chatbot_on_xpu.ipynb for additional notes on the dependencies.
# Working model loaders:
#  - llama.cpp
#  - transformers

pip install intel-extension-for-transformers

# Install xpu intel pytorch, not cpu.

pip install torch==2.1.0a0 torchvision==0.16.0a0 torchaudio==2.1.0a0 intel-extension-for-pytorch==2.1.10+xpu --extra-index-url https://pytorch-extension.intel.com/release-whl/stable/xpu/us/

# Installing these from requriements_cpu_only.txt causes dependency with intel pytorch.

# Install a few of the dependencies for the below.
pip install coloredlogs datasets sentencepiece

pip install --no-deps peft==0.7.* optimum==1.16.* optimum-intel accelerate==0.25.*

# Skip llama-cpp-python install and all installed above without their deps.

grep -v -e peft -e optimum -e accelerate -e llama-cpp-python requirements_cpu_only.txt > temp_requirements.txt

pip install -r temp_requirements.txt

# Install the cpuinfo dependency installed by one_click
pip install py-cpuinfo==9.0.0

# Use the correct cmake args for llama-cpp

export CMAKE_ARGS="-DLLAMA_CLBLAST=ON"
export FORCE_CMAKE=1

pip install --no-cache-dir llama-cpp-python

# List of extensions to exclude
# Exclude coqui_tss because it causes torch dependency issues with intel gpus.
# Whisper_stt and silero_tss both force pytorch updates as dependency of dependency situation. May be possible to use without dependency installation.
cd extensions

extensions=()  # Create an empty array to store folder names
# List of extensions to exclude
# Exclude coqui_tss because it causes torch dependency issues with intel gpus.
# Whisper_stt and silero_tss both force pytorch updates as dependency of dependency situation. May be possible to use without dependency installation.
exclude_extensions=(coqui_tts silero_tts whisper_stt superbooga superboogav2)

for folder in */; do
    extensions+=($folder)
done

echo "${extensions[*]}"

install_extensions=()

for ext in "${extensions[@]}"; do
    should_exclude=false

    for exclude_ext in "${exclude_extensions[@]}"; do
        if [[ "$ext" == *"$exclude_ext"* ]]; then
            should_exclude=true
            break
        fi
    done

    if [ "$should_exclude" = false ]; then
        install_extensions+=("$ext")
    fi
done

# Print the install_extensions
# echo "${install_extensions[@]}"

for extension in ${install_extensions[@]}; do
    cd "$extension"
    echo -e "\n\n$extension\n\n"
    # Install dependencies from requirements.txt
    if [ -e "requirements.txt" ]; then
        echo "Installing requirements in $dir"
        pip install -r requirements.txt
    else
        echo "No requirements.txt found in $dir"
    fi
    cd ..
done
# Leave the extension directory.
cd ..

# Delete the temp_requirements.txt file.

rm temp_requirements.txt

