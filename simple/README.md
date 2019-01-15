# simple

- Simple SDSoC platform

***

## How to create the platform

- Generate HW

```bash
$ vivado -mode batch -source src/bd.tcl
```

- Build PetaLinux project

```bash
# Create project
$ cd petalinux
$ petalinux-create -t project -n u96_base --template zynqMP
$ $ petalinux-config -p u96_base --get-hw-description=.

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
