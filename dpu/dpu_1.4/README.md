# DPU (v1.4) Integration

## Prerequisite

- DPU TRD design (190531)
  - Download _zcu102-dpu-trd-2018-2-190531.zip_ from [Xilinx website](https://www.xilinx.com/products/design-tools/ai-inference/ai-developer-hub.html#edge)

- DNNDK (v3.0; 190531)
  - Download _xlnx_dnndk_v3.0_190531.tar.gz_ also from [Xilinx website](https://www.xilinx.com/products/design-tools/ai-inference/ai-developer-hub.html#edge)

- Extract source

```shell-session
# IP
$ unzip zcu102-dpu-trd-2018-2-190531.zip
$ cp -R zcu102-dpu-trd-2018-2-190531/pl/srcs/dpu_ip src

# Library
$ tar xf xlnx_dnndk_v3.0_190531.tar.gz
$ cd xlnx_dnndk_v3.0_190531
$ tar xf XILINX_AI_SDK-V1.0.0-BUILD-16-2019-05-31.tar.gz
$ tar xf xilinx_dnndk_v3.0_190521.tar.gz
$ cp -R xilinx_dnndk_v3.0/Ultra96/pkgs src
```

***

## Build HW (Generate bitstream)

```shell-session
$ vivado -mode batch -source create_vivado_project.tcl
```
