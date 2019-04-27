# DPU

## Environment

- Vivado / PetaLinux version: 2018.3
- OS: Ubuntu 16.04

***

## Get source from GitHub

- Clone

```shell-session
$ git clone https://github.com/Xilinx/Edge-AI-Platform-Tutorials.git
```

***

## Build HW in Vivado

- Edit _Edge-AI-Platform-Tutorials/docs/DPU-Integration/reference-files/vivado_ to use version 2018.3

  - Before:
  
  ```tcl
  set scripts_vivado_version 2018.2
  ```
  
  - After:
  
  ```tcl
  set scripts_vivado_version 2018.3
  ```

- Generate bitstream & HW definition

```shell-session
$ vivado -mode batch -source create_vivado_project.tcl
```

***

## Build PetaLinux

```shell-session
$ export PRJ_NAME=petalinux
$ petalinux-build -p ${PRJ_NAME}

# Generate BOOT.BIN (Overwrite exsiting one)
$ petalinux-package -p ${PRJ_NAME} --boot --format BIN \
--force \
--fsbl petalinux/images/linux/zynqmp_fsbl.elf \
--u-boot ${PRJ_NAME}/images/linux/u-boot.elf \
--fpga _vivado/u96_dpu.runs/impl_1/design_1_wrapper.bit

# Copy output product
$ cp petalinux/images/linux/image.ub _sd_card
$ cp petalinux/images/linux/BOOT.BIN _sd_card
```

***

## Build SW (ResNet50 application)

- Rename directory that contains DNNDK Header

```shell-session
$ export SRC_DIR=$(pwd)/Edge-AI-Platform-Tutorials/docs/DPU-Integration/reference-files/files

$ cp -R ${SRC_DIR}/recipes-apps/dnndk/files/include ${SRC_DIR}/recipes-apps/dnndk/files/dnndk
```

- Create symbolic link to libdputils.so

```shell-session
$ cd ${SRC_DIR}/recipes-apps/dnndk/files/lib
$ ln -s libdputils.so.3.1 libdputils.so
$ cd ${OLDPWD}
```

- Build

```shell-session
$ aarch64-linux-gnu-g++ ${SRC_DIR}/resnet50/main.cc \
-Wall -O3 \
-c -o main.o \
-Ipetalinux/build/tmp/sysroots-components/aarch64/opencv/usr/include \
-I${SRC_DIR}/recipes-apps/dnndk/files

$ aarch64-linux-gnu-g++ -o _sd_card/resnet50.elf main.o \
${SRC_DIR}/resnet50/B1152_1.3.0/dpu_resnet50_0.elf \
${SRC_DIR}/resnet50/B1152_1.3.0/dpu_resnet50_2.elf \
-Lpetalinux/build/tmp/sysroots-components/aarch64/opencv/usr/lib \
-Lpetalinux/build/tmp/sysroots-components/aarch64/libpng/usr/lib \
-Lpetalinux/build/tmp/sysroots-components/aarch64/zlib/usr/lib \
-Lpetalinux/build/tmp/sysroots-components/aarch64/tbb/usr/lib \
-L${SRC_DIR}/recipes-apps/dnndk/files/lib \
-lopencv_core -lopencv_imgcodecs -lopencv_highgui -lopencv_imgproc \
-lpng -lz -ltbb -ln2cube -ldputils
```

***

## Run

- Copy image data

```shell-session
$ cp -R ${SRC_DIR}/../sdcard/common _sd_card
```

- Copy the content of __sd_card_ into micro SD card

- Run the application

```shell-session
# Install DPU kernel module
$ insmod /lib/modules/4.14.0-xilinx-v2018.3/extra/dpu.ko

# ResNet50
$ ./resnet50.elf
```

***

## Reference

- [DPU Integration Lab (UG1350)](https://github.com/Xilinx/Edge-AI-Platform-Tutorials/blob/master/docs/DPU-Integration/README.md)
