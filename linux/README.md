# linux

- Large linux rootfs with various libraries
  - Not RAM disk image
  - SDSoC capable

***

## Build hardware

- Generate bitstream

```bash
# This will also create HW definition file (_system.hdf)
$ vivado -mode batch -source create_vivado_project.tcl
```

***

## Create PetaLinux project

- Create project (usually can be skipped to "petalinux-build")

```bash
$ export PRJ_NAME=prj
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

***

## Generate BOOT.bin

```bash
$ bootgen -arch zynqmp -image src/boot_bin_linux.bif -w -o BOOT.bin
# or ...
$ petalinux-package -p ${PRJ_NAME} --boot --format BIN \
> --fsbl ${PRJ_NAME}/images/linux/zynqmp_fsbl.elf \
> --u-boot ${PRJ_NAME}/images/linux/u-boot.elf \
> --pmufw ${PRJ_NAME}/images/linux/pmufw.elf \
> --fpga _vivado/hw.runs/impl_1/hw_wrapper.bit \
> --atf ${PRJ_NAME}/images/linux/bl31.elf
# BOOT.BIN is in ${PRJ_NAME}/images/linux/
```

***

## Run

- Copy BOOT.bin & image.ub into 1st partition of SD card

- Untar rootfs.tar.bz2 (or rootfs.tar.gz) into 2nd partition of SD card

- Power-up the board

***

## Simulation in QEMU

```bash
# Collect prebuilt image
$ cd ${PRJ_NAME}
$ petalinux-package --prebuilt
# Run Linux Kernel
$ cp ../src/pmu_rom_qemu_sha3.elf pre-built/linux/images/
$ petalinux-boot --qemu --kernel
```

***

## Tips

- How to add libsdslib*.so

    ```bash
    $ petalinux-create -p ${PRJ_NAME} -t apps --template install --name sdslib --enable
    $ rm ${PRJ_NAME}/project-spec/meta-user/recipes-apps/sdslib/files/sdslib
    $ cp -R ${XILINX_SDX}/target/aarch64-linux/lib/libsds_lib*.so ${PRJ_NAME}/project-spec/meta-user/recipes-apps/sdslib/files

    # Edit .bb file
    $ nano ${PRJ_NAME}/project-spec/meta-user/recipes-apps/sdslib/sdslib.bb
    ```

- Where to get constraint file (ultra96v1_petalinux.xdc): [https://github.com/Avnet/hdl/blob/master/Projects/ultra96v1_petalinux/ultra96v1_petalinux.xdc](https://github.com/Avnet/hdl/blob/master/Projects/ultra96v1_petalinux/ultra96v1_petalinux.xdc)

- Where to get pmu_rom_qemu_sha3.elf
  - Download PetaLinux BSP from Xilinx website
  - Untar the BSP
  - pmu_rom_qemu_sha3.elf is in pre-built/linux/images/
