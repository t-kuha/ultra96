# UG1338

- DPU: v2.0
- DNNDK: v3.0 (20190624)
- Vivado: 2018.3
- CPU only (No GPU is used)

## Evaluate frozen graph

```shell-session
$ python eval_graph.py \
>   --graph ./freeze/frozen_graph.pb \
>   --input_node images_in \
>   --output_node dense_1/BiasAdd
```

- Result:

```shell-session
Optimizing fused batch norm node name: "batch_normalization/FusedBatchNorm"                                   |
op: "FusedBatchNorm"
input: "conv2d/Relu"
input: "batch_normalization/gamma"
input: "batch_normalization/beta"
input: "batch_normalization/moving_mean"
input: "batch_normalization/moving_variance"
device: "/job:localhost/replica:0/task:0/device:CPU:0"
    ...
 Top 1 accuracy with validation set: 0.8033
 Top 5 accuracy with validation set: 0.9868
FINISHED!
```

## Quantize graph

```shell-session
decent_q quantize \
    --input_frozen_graph ./freeze/frozen_graph.pb \
    --input_nodes images_in \
    --input_shapes ?,32,32,3 \
    --output_nodes dense_1/BiasAdd \
    --method 1 \
    --input_fn default \
    --calib_iter 100 \
    --batch_size 50 \
    --image_dir ./calib_dir \
    --image_list ./calib_dir/calib_list.txt \
    --scales 0.00392,0.00392,0.00392
```

- Result:

```shell-session
Total images for calibration: 10000
calib_iter: 100
batch_size: 50
INFO: Start Float Graph Check
Optimizing fused batch norm node name: "batch_normalization/FusedBatchNorm"
    ...
Total images for calibration: 10000
calib_iter: 100
batch_size: 50
INFO: Start Calibration for 100 iterations:
100% |########################################################################################################|
INFO: Done Calibration
INFO: Start Generate Deploy Model
INFO: End Generate Deploy Model
********************* Quantization Summary *********************
INFO: Output:
  quantize_eval_model: ./quantize_results/quantize_eval_model.pb
  deploy_model: ./quantize_results/deploy_model.pb
```

## Evaluate quantized graph

```shell-session
python eval_graph.py \
  --graph ./quantize_results/quantize_eval_model.pb \
  --input_node images_in \
  --output_node dense_1/BiasAdd
```

- Result:

```shell-session
 Top 1 accuracy with validation set: 0.8065
 Top 5 accuracy with validation set: 0.9871
FINISHED!
```

## Compile

- The dnnc-dpu1.4.0 is for DPU with low RAM Usage and the dnnc-dpu1.4.0.1 is for DPU with high RAM Usage.

```shell-session
dnnc-dpu1.4.0 \
    --parser=tensorflow \
    --frozen_pb=./quantize_results/deploy_model.pb \
    --dpu=2304FA \
    --cpu_arch=arm64 \
    --output_dir=deploy \
    --save_kernel \
    --mode normal \
    --net_name=cifar10
```

- Result

```shell-session
DNNC Kernel Information
1. Overview
kernel numbers  : 1
kernel topology : cifar10_kernel_graph.jpg
2. Kernel Description in Detail
kernel id       : 0
kernel name     : cifar10
type            : DPUKernel
nodes           : NA
input node(s)   : conv2d_Conv2D(0) 
output node(s)  : dense_1_MatMul(0) 
```

## Build .elf

```shell-session
$ aarch64-linux-gnu-g++ src/main.cpp \
>   -Wall -O3 \
>   --sysroot=/opt/petalinux/2018.2/sysroots/aarch64-xilinx-linux \
>   -I../../../dnndk/xlnx_dnndk_v3.0_190624/xilinx_dnndk_v3.0/Ultra96/pkgs/include \
>   -L../../../dnndk/xlnx_dnndk_v3.0_190624/xilinx_dnndk_v3.0/Ultra96/pkgs/lib \
>   -lopencv_core -lopencv_highgui -lopencv_imgproc -lopencv_imgcodecs -lopencv_videoio \
>   -lpthread -ln2cube -ldputils -lhineon \
>   deploy/dpu_cifar10.elf -o ug1338.elf
```

## Generate test images

- Run the Jupyter Notebook in _jupyter-notebook_

## Run

```shell-session
root@ultra96:~# /media/ug1338.elf
------ DPU (CIFAR-10) ------
..... Pre-loading Images .....
..... Start Inference .....
..... Inference Result .....
3, 8, 8, 0, 6, 5, 1, 6, 3, 1, 4, 9, 5, 7, 9, 8, 5, 7, 8, 6,
7, 0, 4, 9, 4, 3, 4, 0, 9, 6, 6, 5, 4, 3, 9, 3, 7, 9, 9, 5,
  ...
0, 3, 4, 8, 4, 2, 6, 6, 5, 6, 2, 9, 4, 0, 1, 7, 5, 5, 7, 3,
0, 4, 6, 1, 7, 5, 8, 0, 8, 4, 7, 0, 3, 3, 3, 5, 6, 5, 1, 7,
-------------------------
```
