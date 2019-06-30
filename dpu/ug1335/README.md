# UG1335

## Quantize trained model

```shell-session
$ decent-cpu quantize \
-model _model/float.prototxt \
-weights _model/float.caffemodel \
-output_dir $(pwd)/_quant \
-method 1
```

## Compile quantized model

```shell-session
dnnc \
--prototxt=_quant/deploy.prototxt     \
--caffemodel=_quant/deploy.caffemodel \
--output_dir=_deploy \
--net_name=miniVggNet \
--dpu=2304FA \
--cpu_arch=arm64 \
--mode=normal \
--save_kernel
```

## Make .elf

```shell-session
$ aarch64-linux-gnu-g++ src/top5_main.cc \
--sysroot=/opt/petalinux/2018.2/sysroots/aarch64-xilinx-linux \
-I../../../dnndk/xlnx_dnndk_v3.0_190624/xilinx_dnndk_v3.0/Ultra96/pkgs/include \
-L../../../dnndk/xlnx_dnndk_v3.0_190624/xilinx_dnndk_v3.0/Ultra96/pkgs/lib \
-lopencv_core -lopencv_highgui -lopencv_imgproc -lopencv_imgcodecs -lopencv_videoio \
-lpthread -ln2cube -ldputils -lhineon \
_deploy/dpu_miniVggNet_0.elf -o ug1335.elf
```

## Run

```shell-session
root@ultra96:~# ./ug1335.elf 6
total image : 6
DBG imread DBG imread DBG imread ./test_images/airplane_00004.jpg./test_images/airplane_00006.jpgDBG imread ./test_image
s/airplane_00001.jpg


./test_images/airplane_00002.jpg
DBG imread ./test_images/airplane_00003.jpg
DBG imread ./test_images/airplane_00005.jpg
[Top]0 prob = 0.996501  name = airplane
[Top]1 prob = 0.002470  name = cat
[Top]2 prob = 0.000334  name = dog
[Top]3 prob = 0.000203  name = frog
[Top]4 prob = 0.000203  name = deer
[Top]0 prob = 0.940611  name = airplane
[Top]1 prob = 0.028404  name = ship
[Top]2 prob = 0.013417  name = dog
[Top]3 prob = 0.006338  name = frog
[Top]4 prob = 0.003844  name = cat
[Top]0 prob = 0.997871  name = airplane
[Top]1 prob = 0.001926  name = truck
[Top]2 prob = 0.000158  name = automobile
[Top]3 prob = 0.000027  name = ship
[Top]4 prob = 0.000017  name = deer
[Top]0 prob = 0.999052  name = airplane
[Top]1 prob = 0.000710  name = bird
[Top]2 prob = 0.000096  name = automobile
[Top]3 prob = 0.000075  name = frog
[Top]4 prob = 0.000028  name = truck
[Top]0 prob = 0.995738  name = airplane
[Top]1 prob = 0.002468  name = bird
[Top]2 prob = 0.001166  name = deer
[Top]3 prob = 0.000429  name = horse
[Top]4 prob = 0.000075  name = automobile
[Top]0 prob = 0.994287  name = airplane
[Top]1 prob = 0.003165  name = cat
[Top]2 prob = 0.001495  name = ship
[Top]3 prob = 0.000550  name = dog
[Top]4 prob = 0.000334  name = deer
[Time]9634us
[FPS]622.794
```
