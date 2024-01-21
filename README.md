# Making Oobabooga and Intel Arc Work Together
These are helpers and scripts for using Intel Arc gpus with oobabooga's text-generation-webui. Contributions welcome.

See the [original post](https://github.com/oobabooga/text-generation-webui/issues/3761#issuecomment-1902748914) for more details.

This is just a starting point. Changes are welcome. Once it's right in bash, we can decide whether to integrate it with oobabooga's start_linux.sh, requirements files, and one_click.py.

## Getting Started

1. Download or clone a fresh copy of Oobabooga.
2. Save the below scripts into `text-generation-webui`. These should be in the same folder as `one_click.py`, `cmd_linux.sh`, etc.
3. Make them executable.

   ```bash
   cd text-generation-webui
   ./install_arch.sh
   ```

4. Check `clinfo` for your hardware information.

   ```bash
   clinfo -l
   ```

5. In `run_arc.sh`, find `GGML_OPENCL_PLATFORM` and change it to your platform number. Then change the `GGML_OPENCL_DEVICE` to your device name. Save the file.

6. Start the server with `run_arch.sh`. This uses any flags you've saved in `CMD_FLAGS.txt`. You can also use flags like `--listen --api` with the script.

   ```bash
   ./run_arch.sh
   ```
