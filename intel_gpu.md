# Draft Guide for Running Ooobabooga on Intel Arc

**More eyes and testers are needed before any submissions to the main repository.**

*Although hacking conda's OpenCL vendor files is a viable option, swapping to a standard python3 install and using a venv resulted in improved performance in tokens/s by approximately 71% across all models tested.. It also eliminates possible issues with older conda libraries and bleeding edge ones needed for Intel Arc. For now, skipping conda and its CDTs appears to be the most reliable option.*

Working model loaders:

*   llama.cpp

*   transformers

The latest Intel extension for transformers added INT4 inference support for Arc. Hugging Face transformers committed XPU support for the trainer in September '23. If any of the other model loaders use transformers, they may run with little effort. (They may also require a fairly major fork. In which case, adding a (BigDL)\[<https://github.com/intel-analytics/BigDL>] model loader is probably a better use of energy. That's just my opinion. My BigDL experiments are still in jupyter notebooks, but it's been a good experience on both the Intel gpu and the cpu.)

*Note, loaders are hardcoded in modules/loaders.py. Without refactoring this be more modular like extensions or \[shudder] monkeypatching, we just need to remember which ones work with our individual system. Making it more modular and customizable for different combinations of cpus and gpus is a much broader discussion than getting this working on the Intel Arc. It would also need a lot of buy-in and commitment from the community.*

Models tested:

*   transformers

    *   llama2-7b-chat-hf

    *   mistralai\_Mistral-7B-Instruct-v0.2

*   llama.cpp

    *   llama-2-7b-chat.Q5\_K\_M.gguf

    *   mistral-7b-instruct-v0.2.Q5\_K\_M.gguf

What isn't tested:

*   Most models

*   Training

*   Parameters

*   Extensions

    *   Note, coqui\_tss, silero\_tts, whisper\_stt, superbooga, and superboogav2 are all breaking installs. It may be possible to install their requirements without any dependencies and then pick up the additional dependencies during debugging. TTS, in particular, upgrades torch to the wrong version for the Intel extension.

Install notes:

*   Latest Intel Arc drivers installed. See (Intel client GPU installation docs.)\[<https://dgpu-docs.intel.com/driver/client/overview.html>]

*   (Intel OneAPI basekit installed)\[<https://www.intel.com/content/www/us/en/developer/tools/oneapi/base-toolkit-download.html>]

*   Install `opencl-headers ocl-icd libclblast-dev  python3 python3-pip python3-venv libgl1 libglib2.0-0 libgomp1 libjemalloc-dev`

    *   Note, libclblast-dev >= 1.6

*   Your username is part of the renderer group.

*   You have hangcheck disabled in grub.

*The last two items are just standard things I do with a fresh install or new graphics card. They may no longer be necessary. If you've already installed these, check for updates. Intel kicked off 2024 with a lot of updates.*

Test Machine Details:

*   Ubuntu 23.10

*   6.5.0.14.16 generic linux

*   i7-13700k CPU (runs the display)

*   Intel Arc A770 (non-display)

Below are 2 bash scripts: install\_arch.sh and run\_arch.sh. They need be saved in the text-generation-webui directory.

# Getting started

1.  Download or clone a fresh copy of oobabooga.

2.  Save the below scripts into text-generation-webui. These should be in the same folder as one\_click.py, cmd\_linux.sh, etc.

3.  Make them executable.

<!---->

    cd text-generation-webui
    ./install_arch.sh

1.  Check clinfo for your hardware information.

<!---->

    clinfo -l

1.  In run\_arc.sh, find GGML\_OPENCL\_PLATFORM and change it to your platform number. Then change the GGML\_OPENCL\_DEVICE to your device name. Save the file.

2.  Start the server with run\_arch.sh. This uses any flags you've saved in CMD\_FLAGS.txt. You can also use flags like `--listen --api` with the script.

<!---->

    ./run_arch.sh

## Code for install\_arch.sh

```
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

```

## Code for run\_arc.sh

```
#!/bin/bash

# Activate virtual environment built with install_arc.sh. (Not conda!)
source venv/bin/activate

# Change these values to match your card in clinfo -l
# Needed by llama.cpp

export GGML_OPENCL_PLATFORM=2
export GGML_OPENCL_DEVICE=A770

# Use sudo intel_gpu_top to view your card.

# Capture command-line arguments
flags_from_cmdline=$@

# Read flags from CMD_FLAGS.txt
flags_from_file=$(grep -v '^#' CMD_FLAGS.txt | grep -v '^$')
# Combine flags from both sources
all_flags="$flags_from_file $flags_from_cmdline"

# Run the Python script with the combined flags
python server.py $all_flags

```
