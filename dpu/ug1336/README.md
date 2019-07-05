# UG1336 - Cats vs. Dogs Caffe Tutorial

## Quantize model

```shell-session
decent-cpu \
    quantize \
    -model model/float.prototxt \
    -weights model/float.caffemodel \
    -output_dir quant \
    -method 1
```

- Result:

```shell-session
WARNING: Logging before InitGoogleLogging() is written to STDERR
I0703 04:13:17.986168  2477 decent.cpp:248] Use CPU.
I0703 04:13:18.469063  2477 net.cpp:369] The NetState phase (0) differed from the phase (1) specified by a rule
 in layer data
I0703 04:13:18.469136  2477 net.cpp:369] The NetState phase (0) differed from the phase (1) specified by a rule
 in layer accuracy
I0703 04:13:18.469146  2477 net.cpp:369] The NetState phase (0) differed from the phase (1) specified by a rule
 in layer accuracy-top1
I0703 04:13:18.469542  2477 net.cpp:98] Initializing net from parameters:
    ...
I0703 04:15:23.614611  2477 net.cpp:330] Network initialization done.
I0703 04:15:23.618721  2477 decent.cpp:349] Start Deploy
I0703 04:15:25.991989  2477 decent.cpp:357] Deploy Done!
--------------------------------------------------
Output Deploy Weights: "quant/deploy.caffemodel"
Output Deploy Model:   "quant/deploy.prototxt"
```

## Compile model

```shell-session
dnnc \
    --prototxt=quant/deploy.prototxt \
    --caffemodel=quant/deploy.caffemodel \
    --output_dir=deploy \
    --net_name=alexnetBNnoLRN \
    --dpu=2304FA \
    --cpu_arch=arm64 \
    --mode=normal \
    --save_kernel
```

- Result:

```shell-session
[DNNC][Warning] layer [loss] is not supported in DPU, deploy it in CPU instead.

DNNC Kernel Information
1. Overview
kernel numbers  : 2
kernel topology : alexnetBNnoLRN_kernel_graph.jpg
2. Kernel Description in Detail
kernel id       : 0
kernel name     : alexnetBNnoLRN_0
type            : DPUKernel
nodes           : NA
input node(s)   : conv1(0) 
output node(s)  : fc8(0) 
kernel id       : 1
kernel name     : alexnetBNnoLRN_1
type            : CPUKernel
nodes           : NA
input node(s)   : loss 
output node(s)  : loss
```

## Build .elf

```shell-session
$ aarch64-linux-gnu-g++ src/main.cc \
>   -Wall -O3 \
>   --sysroot=/opt/petalinux/2018.2/sysroots/aarch64-xilinx-linux \
>   -I../../../dnndk/xlnx_dnndk_v3.0_190624/xilinx_dnndk_v3.0/Ultra96/pkgs/include \
>   -L../../../dnndk/xlnx_dnndk_v3.0_190624/xilinx_dnndk_v3.0/Ultra96/pkgs/lib \
>   -lopencv_core -lopencv_highgui -lopencv_imgproc -lopencv_imgcodecs -lopencv_videoio \
>   -lpthread -ln2cube -ldputils -lhineon -lpthread \
>   deploy/dpu_alexnetBNnoLRN_0.elf -o ug1336.elf
```

## Run

```shell-session
root@ultra96:~# ./ug1336.elf 10
total image : 1000
DBG imread DBG imread _test_images/dog.11949.jpg_test_images/cat.4904.jpgDBG imread

_test_images/cat.12413.jpg
DBG imread _test_images/dog.5811.jpg
DBG imread _test_images/cat.8571.jpg
DBG imread _test_images/cat.3857.jpg
DBG imread _test_images/cat.8823.jpg
DBG imread DBG imread _test_images/dog.8835.jpg
_test_images/cat.10902.jpg
DBG imread _test_images/dog.6647.jpg
[Top]0 prob = 0.891811  name = dog
[Top]1 prob = 0.108189  name = cat
DBG imread _test_images/dog.8975.jpg
[Top]0 prob = 0.867036  name = dog
[Top]1 prob = 0.132964  name = cat
    ...
[Top]0 prob = 0.959154  name = dog
[Top]1 prob = 0.040846  name = cat
[Time]9333948us
[FPS]107.136
```
