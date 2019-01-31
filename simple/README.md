# simple

- Simple SDSoC platform

***

## How to create the platform

### Generate HW

```bash
$ vivado -mode batch -source src/bd.tcl
```

### Build PetaLinux project

```bash
# Create project
$ cd petalinux
$ petalinux-create -t project -n u96_base --template zynqMP
$ petalinux-config -p u96_base --get-hw-description=.

# Kernel config
$ petalinux-config -p u96_base -c kernel

# u-boot config
$ petalinux-config -p u96_base -c u-boot

# rootfs config
$ petalinux-config -p u96_base -c rootfs

# Add libsdslib*.so
$ petalinux-create -p u96_base -t apps --template install --name sdslib --enable
$ rm u96_base/project-spec/meta-user/recipes-apps/sdslib/files/sdslib
$ cp -R ${XILINX_SDX}/target/aarch64-linux/lib/libsds_lib*.so u96_base/project-spec/meta-user/recipes-apps/sdslib/files
# Edit .bb file
$ nano u96_base/project-spec/meta-user/recipes-apps/sdslib/sdslib.bb

# Build
$ petalinux-build -p u96_base
```

### Create initial SDSoC platform (without pre-built HW)

```bash
# Create directory for platform components
$ mkdir pfm_files/boot pfm_files/image

# Copy necessary output products
$ cp petalinux/u96_base/images/linux/u-boot.elf      pfm_files/boot/u-boot.elf
$ cp petalinux/u96_base/images/linux/zynqmp_fsbl.elf pfm_files/boot/fsbl.elf
$ cp petalinux/u96_base/images/linux/bl31.elf        pfm_files/boot/bl31.elf
$ cp petalinux/u96_base/images/linux/pmufw.elf       pfm_files/boot/pmufw.elf
$ cp petalinux/u96_base/images/linux/image.ub        pfm_files/image/image.ub

# Make sure to use xsct in SDx (not SDK)
$ xsct create_sdsoc_pfm.tcl
```

### Build pre-built HW

- Build _hello_world_

```bash
$ mkdir _prj_init
$ cd _prj_init
$ sdscc ../src/hello_world.c -c -o hello_world.o -sds-pf ../platform/u96_base/export/u96_base -sds-sys-config linux -target-os linux
$ sdscc hello_world.o -o hello_world.elf -sds-pf ../platform/u96_base/export/u96_base -sds-sys-config linux -target-os linux
```

- Copy prebuilt data

```bash
$ mkdir pfm_files/prebuilt

# system.bit file should be renamed to bitstream.bit
$ cp _prj_init/_sds/p0/vpl/system.bit    pfm_files/prebuilt/bitstream.bit
# system.hdf file should be renamed to <platform>.hdf
$ cp _prj_init/_sds/p0/vpl/system.hdf    pfm_files/prebuilt/u96_base.hdf
$ cp _prj_init/_sds/.llvm/partitions.xml pfm_files/prebuilt
$ cp _prj_init/_sds/.llvm/apsys_0.xml    pfm_files/prebuilt
$ cp _prj_init/_sds/swstubs/portinfo.c   pfm_files/prebuilt
$ cp _prj_init/_sds/swstubs/portinfo.h   pfm_files/prebuilt
```

### Create final platform (with pre-built HW)

```bash
$ xsct create_sdsoc_pfm.tcl
```

***

## Tips

- Console setting must be changed from default (ps_uart_0) to ps_uart_1. To do that, use petalinux-config command.

- To use USB ports, ULPI option in Linux Kernel config must be enabled.

- Where to get the firmware of WL1831:
  - git://git.ti.com/wilink8-wlan/wl18xx_fw.git (Wi-Fi)
  - git://git.ti.com/wilink8-bt/ti-bt-firmware.git (Bluetooth)
