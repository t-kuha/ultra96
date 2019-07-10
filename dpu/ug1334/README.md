# UG1334 - YOLOv3 Tutorial: Darknet to Caffe to Xilinx DNNDK

## Compile quantized model

```shell-session
$ mkdir model

$ dnnc \
>   --prototxt=deploy/deploy.prototxt \
>   --caffemodel=deploy/deploy.caffemodel \
>   --dpu=2304FA \
>   --cpu_arch=arm64 --output_dir=$(pwd)/model \
>   --net_name=yolo --mode=normal --save_kernel
```

- Result:

```shell-session
DNNC Kernel Information

1. Overview
kernel numbers  : 1
kernel topology : yolo_kernel_graph.jpg

2. Kernel Description in Detail
kernel id       : 0
kernel name     : yolo
type            : DPUKernel
nodes           : NA
input node(s)   : layer0_conv(0) 
output node(s)  : layer81_conv(0) layer93_conv(0) layer105_conv(0) 
```

***

## Compile executable

```shell-session
$ aarch64-linux-gnu-g++ src/main.cc \
>   --sysroot=/opt/petalinux/2018.2/sysroots/aarch64-xilinx-linux \
>   -I../../../dnndk/xlnx_dnndk_v3.0_190624/xilinx_dnndk_v3.0/Ultra96/pkgs/include \
>   -L../../../dnndk/xlnx_dnndk_v3.0_190624/xilinx_dnndk_v3.0/Ultra96/pkgs/lib \
>   -lopencv_core -lopencv_highgui -lopencv_imgproc -lopencv_imgcodecs -lopencv_videoio \
>   -lpthread -ln2cube -ldputils -lhineon \
>   deploy/dpu_yolo.elf -o ug1334.elf
```

***

## Run

```shell-session
# Install DPU kernel module
root@ultra96:~# modprobe dpu

# Run
root@ultra96:~# ./yolo_v3.elf coco_test.jpg i
boxes size: 19
0.991876 44.9521 30.4065 351.873 472.416
0.620821 47.038 236.548 192.493 371.538
0.124843 10.3188 47.7135 358.106 489.723
0.180861 10.3188 47.7135 358.106 489.723
```

- Result:

![yolo detection result](result.jpg)
