# DPU (v2.0) Integration

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

# Kernel module
$ cd zcu102-dpu-trd-2018-2-190531/apu/dpu_petalinux_bsp
$ petalinux-create -t project -s xilinx-dpu-trd-zcu102-v2018.2.bsp
$ cp -R zcu102-dpu-trd-2018-2/project-spec/meta-user/recipes-modules/dpu ../../../src

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

- About interrupt:
  - "If DPU is integrated in MPSoC and working with the DNNDK package, you should connect the dpu_interrupt at the bit 10 in the irq signal of PS."
  - "If the option of softmax in DPU is set as enable, then the interrupt of softmax should connect at the bit 14 in the irq signal of PS when DPU is working with the DNNDK package."
  - "irq15~irq8 corresponds to pl_ps_irq1[7:0]."

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
$ cp -R src/dpu/* prj/project-spec/meta-user/recipes-modules/dpu/

＃ Add DNNDK files
$ petalinux-create -p ${PRJ_NAME} -t apps --template install --name dnndk --enable
$ rm prj/project-spec/meta-user/recipes-apps/dnndk/files/dnndk
$ cp -R src/pkgs/bin prj/project-spec/meta-user/recipes-apps/dnndk/files/
$ cp -R src/pkgs/lib prj/project-spec/meta-user/recipes-apps/dnndk/files/

# Add DPU driver (Kernel module)
$ petalinux-create -p ${PRJ_NAME} -t modules --name dpu --enable
$ cp -R src/dpu/* prj/project-spec/meta-user/recipes-modules/dpu/

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

## Reference

- [DPU for Convolutional Neural Network v2.0 - DPU IP Product Guide](https://www.xilinx.com/support/documentation/ip_documentation/dpu/v2_0/pg338-dpu.pdf)
- [Device trees of DPU](https://forums.xilinx.com/t5/Deephi-DNNDK/Device-trees-of-DPU/m-p/953420)


- Clocking
  - "There are three input clocks for the DPU in which the frequency of the dpu_2x_clk should be two times the m_axi_dpu_aclk and the two clocks must be synchronous to meet the timing closure."
  - "Note that the parameter of the Primitive must be set to Auto."
  - "Select the Matched Routing for the m_axi_dpu_aclk and dpu_2x_clk in the Output Clocks tab of the Clock Wizard IP. "

- Reset
  - ""
- Register Address
  - "DPU base address must be set to 0x8F00_0000 with a range of 16 MB in MPSoC series."
