# How to deploy network

## Environment

- OS: Ubuntu 16:04
- DNNDK: [xlnx_dnndk_v2.08_190201.tar.gz](https://japan.xilinx.com/products/design-tools/ai-inference/ai-developer-hub.html)

## Install DNNDK

```shell-session
$ tar xf xlnx_dnndk_v2.08_190201.tar.gz
$ 
```

***

## Download pre-trained model

```shell-session
$ wget http://www.deephi.com/assets/ResNet50.tar.gz

# Other models are available...
$ wget http://www.deephi.com/assets/Inception_v1.tar.gz
$ wget http://www.deephi.com/assets/VGG16.tar.gz
```

## Quantize

```shell-session
$ decent quantize \
-model float.prototxt \
-weights float.caffemodel \
-output_dir test -method 1
```

- __Note:__ Quantization of VGG16 model requires ~8GB of RAM while other models require only ~2GB

## Compile DPU model

```shell-session
$ dnnc-dpu1.3.0 \
--prototxt=test/deploy.prototxt  \
--caffemodel=test/deploy.caffemodel \
--dpu=1152FA --cpu_arch=arm64 \
--output_dir=./test --net_name=resnet50
```
