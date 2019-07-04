# UG1338


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

```shell-session
dnnc \
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


## Run
