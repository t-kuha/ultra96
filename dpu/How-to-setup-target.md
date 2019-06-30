# Preparing Ultra96 image

## Ultra96 image

- Download the image (_xilinx-ultra96-prod-dpu1.4-desktop-buster-2019-05-31.img.zip_) from [Xilinx website](https://www.xilinx.com/products/design-tools/ai-inference/ai-developer-hub.html#edge)

- Unzip the .zip & copy the image to micro SD card

```shell-session
$ unzip xilinx-ultra96-prod-dpu1.4-desktop-buster-2019-04-23.img.zip
$ sudo dd if=xilinx-ultra96-prod-dpu1.4-desktop-buster-2019-04-23.img of=/dev/sdc conv=fsync
```

## DNNDK

- Donwload DNNDK (xlnx_dnndk_v3.0_190624.tar.gz) from [Xilinx website](https://www.xilinx.com/products/design-tools/ai-inference/ai-developer-hub.html#edge)

- Untar the DNNDK & copy the content to micro SD card

```shell-session
$ tar xf xlnx_dnndk_v3.0_190624.tar.gz
$ cd xlnx_dnndk_v3.0_190624
$ tar xf xilinx_dnndk_v3.0_190624.tar.gz
$ sudo cp -R  xilinx_dnndk_v3.0/Ultra96/* <micro SD card>/ROOTFS/root/
```

## Boot the board

- Install DNNDK on th board

```shell-session
root@ultra96:~# ./install.sh 
Begin to install Xilinx DNNDK ...
Install DPU Driver ...
[   91.723248] dpu: loading out-of-tree module taints kernel.
[   91.730745] [DPU][4059]Checking DPU signature at addr = 0x8ff00000, 
[   91.737278] [DPU][4059]DPU signature checking done!
Install DNNDK tools, runtime & libraries ...
Complete installation successfully.
```

- Run _dexplorer_ to inspect DPU signature information

```shell-session
root@ultra96:~# dexplorer -w
[DPU IP Spec]
IP  Timestamp   : 2019-03-29 16:30:00
DPU Core Count  : 1

[DPU Core List]
DPU Core        : #0
DPU Enabled     : Yes
DPU Arch        : B2304F
DPU Target      : v1.4.0
DPU Freqency    : 260 MHz
DPU Features    : Avg-Pooling, LeakyReLU/ReLU6, Depthwise Conv
```
