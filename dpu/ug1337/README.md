# UG1337 - MNIST Classification with TensorFlow

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

```shell-session
$ dnnc \
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
aarch64-linux-gnu-g++ src/main.cpp
```

## Run


-------------------
-ltbb -lgtk-3 -lglib-2.0 -ldrm -llzma -ltiff -lpng16 -lz -ljpeg -lwebp -lcairo ^
-lpango-1.0 ^

aarch64-linux-gnu-g++ src/main.cpp ^
-Wall ^
-ID:\tmp\dnndk\xlnx_dnndk_v3.0_190624\xilinx_dnndk_v3.0\Ultra96\pkgs\include ^
-ID:\tmp\dnndk\v3.0\_install\include ^
-LD:\tmp\dnndk\xlnx_dnndk_v3.0_190624\xilinx_dnndk_v3.0\Ultra96\pkgs\lib ^
-LD:\tmp\dnndk\v3.0\_install\lib ^
-lopencv_highgui -lopencv_imgproc -lopencv_core -lopencv_imgcodecs -lopencv_videoio ^
-ln2cube -ldputils -lhineon ^
compile/dpu_mnist.elf -o ug1337.elf
