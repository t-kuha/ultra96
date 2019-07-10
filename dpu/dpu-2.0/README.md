# DPU (v1.4) Integration

## Prerequisite

- DPU TRD design (190531)
  - Download _zcu102-dpu-trd-2018-2-190531.zip_ from [Xilinx website](https://www.xilinx.com/products/design-tools/ai-inference/ai-developer-hub.html#edge)

- DNNDK (v3.0; 190624)
  - Download _xlnx_dnndk_v3.0_190624.tar.gz_ also from [Xilinx website](https://www.xilinx.com/products/design-tools/ai-inference/ai-developer-hub.html#edge)

- Extract source

```shell-session
# IP
$ unzip zcu102-dpu-trd-2018-2-190531.zip
$ cp -R zcu102-dpu-trd-2018-2-190531/pl/srcs/dpu_ip src

# Library
$ tar xf xlnx_dnndk_v3.0_190624.tar.gz
$ cd xlnx_dnndk_v3.0_190624
$ tar xf XILINX_AI_SDK-V1.0.0-BUILD-16-2019-05-31.tar.gz
$ tar xf xilinx_dnndk_v3.0_190624.tar.gz
$ cp -R xilinx_dnndk_v3.0/Ultra96/pkgs src
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
$ export PRJ_NAME=petalinux
$ petalinux-create -t project -n ${PRJ_NAME} --template zynqMP
$ petalinux-config -p ${PRJ_NAME} --get-hw-description=.

# Kernel config
$ petalinux-config -p ${PRJ_NAME} -c kernel

# u-boot config
$ petalinux-config -p ${PRJ_NAME} -c u-boot

# rootfs config
$ petalinux-config -p ${PRJ_NAME} -c rootfs

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

***

## Reference

- [DPU for Convolutional Neural Network v2.0 - DPU IP Product Guide](https://www.xilinx.com/support/documentation/ip_documentation/dpu/v2_0/pg338-dpu.pdf)
- [Device trees of DPU](https://forums.xilinx.com/t5/Deephi-DNNDK/Device-trees-of-DPU/m-p/953420)
