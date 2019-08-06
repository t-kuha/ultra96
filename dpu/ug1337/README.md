# UG1337 - MNIST Classification with TensorFlow

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
 Top 1 accuracy with validation set: 0.9902
 Top 5 accuracy with validation set: 0.9999
FINISHED!
```

## Quantize graph

```shell-session
$ decent_q quantize \
>    --input_frozen_graph ./freeze/frozen_graph.pb \
>    --input_nodes images_in \
>    --input_shapes ?,28,28,1 \
>    --output_nodes dense_1/BiasAdd \
>    --method 1 \
>    --input_fn graph_input_fn.calib_input \
>    --calib_iter 200
```

- Result:

```shell-session
INFO: Start Float Graph Check
INFO: Done Float Graph Check
INFO: Start Calibration for 200 iterations:
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
$ python eval_graph.py \
>    --graph ./quantize_results/quantize_eval_model.pb \
>    --input_node images_in \
>    --output_node dense_1/BiasAdd
```

- Result:

```shell-session
 Top 1 accuracy with validation set: 0.9904
 Top 5 accuracy with validation set: 0.9999
FINISHED!
```

## Compile

- The dnnc-dpu1.4.0 is for DPU with low RAM Usage and the dnnc-dpu1.4.0.1 is for DPU with high RAM Usage.

```shell-session
$ dnnc-dpu1.4.0 \
>    --parser=tensorflow \
>    --frozen_pb=./quantize_results/deploy_model.pb \
>    --dpu=2304FA \
>    --cpu_arch=arm64 \
>    --output_dir=deploy \
>    --save_kernel \
>    --mode normal \
>    --net_name=mnist
```

- Result:

```shell-session
DNNC Kernel Information
1. Overview
kernel numbers  : 1
kernel topology : mnist_kernel_graph.jpg
2. Kernel Description in Detail
kernel id       : 0
kernel name     : mnist
type            : DPUKernel
nodes           : NA
input node(s)   : conv2d_Conv2D(0) 
output node(s)  : dense_1_MatMul(0) 
```

## Build .elf

```shell-session
$ aarch64-linux-gnu-g++ src/main.cpp \
>    -Wall -O3 \
>    --sysroot=/opt/petalinux/2018.2/sysroots/aarch64-xilinx-linux \
>    -I../../../dnndk/xlnx_dnndk_v3.0_190624/xilinx_dnndk_v3.0/Ultra96/pkgs/include \
>    -L../../../dnndk/xlnx_dnndk_v3.0_190624/xilinx_dnndk_v3.0/Ultra96/pkgs/lib \
>    -lopencv_core -lopencv_highgui -lopencv_imgproc -lopencv_imgcodecs -lopencv_videoio \
>    -lpthread -ln2cube -ldputils -lhineon \
>    deploy/dpu_mnist.elf -o ug1337.elf
```

## Generate test images

- Run the Jupyter Notebook in _jupyter-notebook_

## Run

```shell-session
root@ultra96:~# /media/ug1337.elf
------ DPU (mnist) ------
..... Pre-loading Images .....
..... Start Inference .....
..... Inference Result .....
7, 2, 1, 0, 4, 1, 4, 9, 5, 9, 0, 6, 9, 0, 1, 5, 9, 7, 3, 4,
9, 6, 6, 5, 4, 0, 7, 4, 0, 1, 3, 1, 3, 4, 7, 2, 7, 1, 2, 1,
  ...
4, 6, 0, 7, 0, 3, 6, 8, 7, 1, 5, 2, 4, 9, 4, 3, 6, 4, 1, 7,
2, 6, 6, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 1, 2, 3, 4, 5, 6,
-------------------------
```
