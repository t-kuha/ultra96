# linux

- Large linux rootfs with various libraries
  - Not RAM disk image
  - SDSoC capable

***

## Build hardware

- Generate bitstream

```bash
$ cd hw
# This will also create HW definition file (_system.hdf)
$ vivado -mode batch -source create_vivado_project.tcl
```

***

## Create PetaLinux project

- Create project

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
```

***

## Generate BOOT.bin

```bash
$ bootgen -arch zynqmp -image src/boot_bin_linux.bif -w -o BOOT.bin
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
