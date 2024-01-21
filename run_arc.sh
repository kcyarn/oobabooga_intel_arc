#!/bin/bash
# Uncomment if oneapi is not in your .bashrc
# source /opt/intel/oneapi/setvars.sh
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
