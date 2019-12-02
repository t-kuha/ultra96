# DPU (v3.0) Integration

- DPU Core Number: 1
- DPU Convolution Architecture: B2304
- RAM Usage: Low
- Softmax: Enabled
- Clock: 300 [MHz]

## Prerequisite

- DNNDK (v3.1; 190809)
  - Download _xilinx_dnndk_v3.1_190809.tar.gz_ also from [Xilinx website](https://www.xilinx.com/products/design-tools/ai-inference/ai-developer-hub.html#edge)

- DPU TRD design (190809)
  - Download _zcu102-dpu-trd-2019-1-190809.zip_ from [Xilinx website](https://www.xilinx.com/products/design-tools/ai-inference/ai-developer-hub.html#edge)

- Extract source

```shell-session
# IP
$ unzip zcu102-dpu-trd-2019-1-190809.zip
$ cp -R zcu102-dpu-trd-2019-1-timer/pl/srcs/dpu_ip src/_dpu_ip

# Kernel module
$ cd zcu102-dpu-trd-2019-1-timer/apu/dpu_petalinux_bsp
$ petalinux-create -t project -s xilinx-dpu-trd-zcu102-v2019.1.bsp
$ cp -R zcu102-dpu-trd-2019-1/project-spec/meta-user/recipes-modules/dpu ../../../src/_driver

# Library
$ tar xf xilinx_dnndk_v3.1_190809.tar.gz
$ cd xilinx_dnndk_v3.1
$ tar xf xilinx_dnndk_v3.1_190809.tar.gz
$ cp -R xilinx_dnndk_v3.1/Ultra96/pkgs src/_pkgs
```

***

## Build HW (Generate bitstream)

- Note: 12 GB or more RAM will be necessary to build the HW

```shell-session
$ vivado -mode batch -source create_vivado_project.tcl
```

***

## Create PetaLinux project

- Create project (usually can be skipped to "petalinux-build")

```shell-session
$ export PRJ_NAME=prj
$ petalinux-create -t project -n ${PRJ_NAME} --template zynqMP
$ petalinux-config -p ${PRJ_NAME} --get-hw-description=.

# Kernel config
$ petalinux-config -p ${PRJ_NAME} -c kernel

# u-boot config
$ petalinux-config -p ${PRJ_NAME} -c u-boot

# rootfs config
# Add opencv & libstdc++
$ petalinux-config -p ${PRJ_NAME} -c rootfs

# Add DNNDK files
$ petalinux-create -p ${PRJ_NAME} -t apps --template install --name dnndk --enable
$ rm -r prj/project-spec/meta-user/recipes-apps/dnndk/files/*
$ cp -R src/_pkgs/bin prj/project-spec/meta-user/recipes-apps/dnndk/files/
$ cp -R src/_pkgs/lib prj/project-spec/meta-user/recipes-apps/dnndk/files/

# Add DPU driver (Kernel module)
$ petalinux-create -p ${PRJ_NAME} -t modules --name dpu --enable
$ cp -R src/_driver/* prj/project-spec/meta-user/recipes-modules/dpu/

# Build
$ petalinux-build -p ${PRJ_NAME}

# Generate SDK (optional)
$ petalinux-build --sdk -p ${PRJ_NAME}
```

- Generate BOOT.bin

```shell-session
$ petalinux-package -p ${PRJ_NAME} --boot --format BIN \
--fsbl ${PRJ_NAME}/images/linux/zynqmp_fsbl.elf \
--u-boot ${PRJ_NAME}/images/linux/u-boot.elf \
--pmufw ${PRJ_NAME}/images/linux/pmufw.elf \
--fpga _vivado/u96_dpu.runs/impl_1/u96_dpu_wrapper.bit \
--atf ${PRJ_NAME}/images/linux/bl31.elf
```

- Or...

```shell-session
$ petalinux-package -p ${PRJ_NAME} --boot --format BIN \
--fsbl ${PRJ_NAME}/images/linux/zynqmp_fsbl.elf \
--u-boot ${PRJ_NAME}/images/linux/u-boot.elf \
--pmufw ${PRJ_NAME}/images/linux/pmufw.elf \
--fpga ${PRJ_NAME}/components/plnx_workspace/device-tree/device-tree/u96_dpu_wrapper.bit \
--atf ${PRJ_NAME}/images/linux/bl31.elf
```

***

## Run

- Copy following files to micro SD card & power up the board
  - prj/images/linux/image.ub
  - prj/images/linux/BOOT.BIN

***

## Reference

- [DPU for Convolutional Neural Network v2.0 - DPU IP Product Guide](https://www.xilinx.com/support/documentation/ip_documentation/dpu/v3_0/pg338-dpu.pdf)
- [Device trees of DPU](https://forums.xilinx.com/t5/Deephi-DNNDK/Device-trees-of-DPU/m-p/953420)
