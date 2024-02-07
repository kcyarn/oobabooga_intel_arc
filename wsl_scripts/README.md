
Please read through these before running them. There are additional notes and instructions in the comments.

## In Windows

Install Intel Driver & Support Assistant in Windows. See [https://www.intel.com/content/www/us/en/support/detect.html](https://www.intel.com/content/www/us/en/support/detect.html)

Launch it. Download and install all available drivers and software updates.

If you have issues downloading the Arc driver with the tool (I did), go [https://www.intel.com/content/www/us/en/download/785597/intel-arc-iris-xe-graphics-windows.html](https://www.intel.com/content/www/us/en/download/785597/intel-arc-iris-xe-graphics-windows.html) and downloaded the latest driver manually. Mine's gfx_win_101.5186_101.5234.exe.

Note, always restart your PC after installing new drivers! 

Install Arc Control. Open it. (It should have installed with the driver.) Click the gear and go to System Info. You should see details for your GPU on the right. Click Drivers on the left. Verify that you have the latest Intel Arc driver installed. As of 2 Feb 2024, this is 31.0.101.5186 with OpenCL Runtime version 3.0 and Vulkan 1.3.271 on Windows 10.

In powershell, run `wsl -l -v`. 

If you haven't installed updated to WSL2, see [https://learn.microsoft.com/en-us/windows/wsl/install](https://learn.microsoft.com/en-us/windows/wsl/install).

Run Powershell as an admin and update WSL2.

```
wsl --update
```
## In WSL Ubuntu

From here, go to step_1.sh and follow the commented instructions. Restart Ubuntu between each step. After step_3.sh,

```
clinfo -l
cd ~/text-generation-webui
nano run_arc.sh
```
Save and exit nano with ctrl + x then y.

Run oobabooga with `.\run_arc.sh`.

