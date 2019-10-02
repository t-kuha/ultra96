# simple

- Simple SDSoC platform

***

## How to create the platform

### Generate HW

```bash
$ vivado -mode batch -source create_vivado_project.tcl
```

### Build PetaLinux project

```bash
# Create project
$ cd petalinux
$ petalinux-config -p u96_base --get-hw-description=.

# Build
$ petalinux-build -p u96_base
```

### Create initial SDSoC platform (without pre-built HW)

```bash
$ ./copy_pfm_files.sh

# Make sure to use xsct in SDx (not the one in SDK)
$ ${XILINX_SDX}/bin/xsct create_sdsoc_pfm.tcl
```

### Build pre-built HW

- Build _hello_world_

```bash
$ mkdir _prj_init
$ cd _prj_init
$ sdscc ../src/hello_world.c -c -o hello_world.o \
-sds-pf ../platform_init/u96_base/export/u96_base -sds-sys-config linux -target-os linux
$ sdscc hello_world.o -o hello_world.elf \
-sds-pf ../platform_init/u96_base/export/u96_base -sds-sys-config linux -target-os linux
```

- Copy prebuilt data

```bash
$ ./copy_prebuilt_files.sh
```

### Create final platform (with pre-built HW)

```bash
$ ${XILINX_SDX}/bin/xsct create_sdsoc_pfm.tcl
```

***

### Confromance Test

- Build:

```bash
$ make OS=LINUX PLATFORM=platform_final/u96_base/export/u96_base PLATFORM_TYPE=MPSOC
```

- Run:

```bash
root@ultra96:~# /media/card/ConformanceTest.elf 
Starting allocation tests from 65536 to 67108864 with increment 524288
done
Starting datamover tests....
Running test <axi_dma_simple, HPC, sds_alloc>
    using Index=1/114687, data size=64-7340032, Allocation=SDS Alloc, Unvalidated
 Complete
Running test <zero_copy, HPC, sds_alloc>
    using Index=1/262143, data size=64-16777216, Allocation=SDS Alloc, Unvalidated
 Complete
Running test <axi_dma_sg, HPC, malloc>
    using Index=1/262143, data size=64-16777216, Allocation=User new, Unvalidated
 Complete
Running test <axi_dma_sg, HPC, sds_alloc>
    using Index=1/262143, data size=64-16777216, Allocation=SDS Alloc, Unvalidated
 Complete
Running test <axi_dma_simple, HP, sds_alloc>
    using Index=1/114687, data size=64-7340032, Allocation=SDS Alloc, Unvalidated
 Complete
Running test <axi_dma_simple, HP, sds_alloc_noncacheable>
    using Index=1/114687, data size=64-7340032, Allocation=SDS Alloc (non-cacheable), Unvalidated
 Complete
Running test <zero_copy, HP, sds_alloc>
    using Index=1/262143, data size=64-16777216, Allocation=SDS Alloc, Unvalidated
 Complete
Running test <zero_copy, HP, sds_alloc_noncacheable>
    using Index=1/262143, data size=64-16777216, Allocation=SDS Alloc (non-cacheable), Unvalidated
 Complete
Running test <axi_dma_sg, HP, malloc>
    using Index=1/262143, data size=64-16777216, Allocation=User new, Unvalidated
 Complete
Running test <axi_dma_sg, HP, sds_alloc>
    using Index=1/262143, data size=64-16777216, Allocation=SDS Alloc, Unvalidated
 Complete
Running test <axi_dma_sg, HP, sds_alloc_noncacheable>
    using Index=1/262143, data size=64-16777216, Allocation=SDS Alloc (non-cacheable), Unvalidated
 Complete
Running test <axi_fifo, NONE, NONE>
    using Index=1/31, data size=64-2048, Allocation=User new, Unvalidated
 Complete
Datamover Testing complete.
Testing clocks
Clock tests complete.
Test passed.
```

***

## How to create PetaLinux project from scratch

```bash
export PRJ=u96_base
# Create project
$ cd petalinux
$ petalinux-create -t project -n ${PRJ} --template zynqMP
$ petalinux-config -p ${PRJ} --get-hw-description=.

# Kernel config
$ petalinux-config -p ${PRJ} -c kernel

# u-boot config
$ petalinux-config -p ${PRJ} -c u-boot

# rootfs config
$ petalinux-config -p ${PRJ} -c rootfs

# Add libsdslib*.so
$ petalinux-create -p ${PRJ} -t apps --template install --name sdslib --enable
$ rm ${PRJ}/project-spec/meta-user/recipes-apps/sdslib/files/sdslib
$ cp -R ${XILINX_SDX}/target/aarch64-linux/lib/libsds_lib*.so \
${PRJ}/project-spec/meta-user/recipes-apps/sdslib/files
# Edit .bb file
$ nano ${PRJ}/project-spec/meta-user/recipes-apps/sdslib/sdslib.bb

# Build
$ petalinux-build -p ${PRJ}
```

***

## Tips

- Console setting must be changed from default (ps_uart_0) to ps_uart_1. 
To do that, use petalinux-config command.

- To use USB ports, ULPI option in Linux Kernel config must be enabled.

- Where to get the firmware of WL1831:
  - git://git.ti.com/wilink8-wlan/wl18xx_fw.git (Wi-Fi)
  - git://git.ti.com/wilink8-bt/ti-bt-firmware.git (Bluetooth)

- HPC port support: [https://www.xilinx.com/html_docs/xilinx2018_3/sdsoc_doc/hbw1532064985184.html](https://www.xilinx.com/html_docs/xilinx2018_3/sdsoc_doc/hbw1532064985184.html)
