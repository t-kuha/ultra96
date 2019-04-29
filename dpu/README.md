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

- Collect headers & libraries

```shell-session
$ mkdir _sysroot
$ cp -R petalinux/build/tmp/sysroots-components/aarch64/opencv/* _sysroot/
$ cp -R petalinux/build/tmp/sysroots-components/aarch64/tbb/*    _sysroot/
$ cp -R petalinux/build/tmp/sysroots-components/aarch64/libpng/* _sysroot/
$ cp -R petalinux/build/tmp/sysroots-components/aarch64/zlib/* _sysroot/
```

***

##  ResNet50 application

### Build SW

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
-I_sysroot/usr/include \
-I${SRC_DIR}/recipes-apps/dnndk/files

$ aarch64-linux-gnu-g++ -o _sd_card/resnet50.elf main.o \
${SRC_DIR}/resnet50/B1152_1.3.0/dpu_resnet50_0.elf \
${SRC_DIR}/resnet50/B1152_1.3.0/dpu_resnet50_2.elf \
-L_sysroot/usr/lib \
-L_sysroot/lib \
-L${SRC_DIR}/recipes-apps/dnndk/files/lib \
-lopencv_core -lopencv_imgcodecs -lopencv_highgui -lopencv_imgproc \
-lpng -lz -ltbb -ln2cube -ldputils
```

### Run

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
$ cd /media/card/common
$ ../resnet50.elf
```

- Result

```shell-session
root@ultra96:/media/card/common# ../resnet50.elf 

Load image : 2ILSVRC2012_test_00000035.JPEG

Run ResNet50 CONV layers ...
  DPU CONV Execution time: 37989us
  DPU CONV Performance: 202.953GOPS
Run ResNet50 FC layers ...
  DPU FC Execution time: 793us
  DPU FC Performance: 5.04414GOPS
top[0] prob = 0.473162  name = gasmask, respirator, gas helmet
top[1] prob = 0.135563  name = spotlight, spot
top[2] prob = 0.064036  name = traffic light, traffic signal, stoplight
top[3] prob = 0.064036  name = loudspeaker, speaker, speaker unit, loudspeaker system, speaker system
top[4] prob = 0.030248  name = reflex camera

...

Load image : ILSVRC2012_test_00099867.JPEG

Run ResNet50 CONV layers ...
  DPU CONV Execution time: 37960us
  DPU CONV Performance: 203.109GOPS
Run ResNet50 FC layers ...
  DPU FC Execution time: 786us
  DPU FC Performance: 5.08906GOPS
top[0] prob = 0.948153  name = weasel
top[1] prob = 0.028632  name = black-footed ferret, ferret, Mustela nigripes
top[2] prob = 0.017366  name = polecat, fitch, foulmart, foumart, Mustela putorius
top[3] prob = 0.002350  name = mink
top[4] prob = 0.000865  name = otter
```

***

## Face Detection

### Build

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
$ aarch64-linux-gnu-g++ app/face_detection.cc \
-Wall -O3 \
-I_sysroot/usr/include \
-c -o face_detection.o \
-I${SRC_DIR}/recipes-apps/dnndk/files

$ aarch64-linux-gnu-g++ -o _sd_card/face_detection.elf face_detection.o \
${SRC_DIR}/face_detection/B1152_1.3.0/dpu_densebox.elf \
-L_sysroot/lib \
-L_sysroot/usr/lib \
-L${SRC_DIR}/recipes-apps/dnndk/files/lib \
-lopencv_core -lopencv_imgcodecs -lopencv_highgui -lopencv_imgproc \
-lpng -lz -ltbb -ln2cube -ldputils
```

### Run

- Copy example image

```shell-session
$ cp app/face.jpg _sd_card
```

- Run the application

```shell-session
root@ultra96:/media/card# ./face_detection.elf
```

- Result

![face_det.jpg](img/face_det.jpg)

***

## Reference

- [DPU Integration Lab (UG1350)](https://github.com/Xilinx/Edge-AI-Platform-Tutorials/blob/master/docs/DPU-Integration/README.md)
