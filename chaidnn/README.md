# chaidnn

## Download source

- Download tarball of CHaiDNN v2 from [GitHub](https://github.com/Xilinx/CHaiDNN/releases)

***

## HW acceleration

- Modify _Makefile_ (line 80)

  - Before:

  ```Makefile
  CFLAGS   := -Wall -O3 -c ${IDIRS} -D__SDSOC=1 -Wno-unused-label  -D__SYNTHESIS__=1
  ```

  - After:
    - Remove "-D__SYNTHESIS__=1"

  ```Makefile
  CFLAGS   := -Wall -O3 -c ${IDIRS} -D__SDSOC=1 -Wno-unused-label
  ```

- Build

```bash
$ make \
CLOCK_ID=1 \
DM_CLOCK_ID=1 \
DECONV_ENABLE=0 \
PLATFORM=/path/to/platform
```

***

## SW only (No acceleration)

- Modify Makefile

  - Before:

  ```Makefile
  xi_convolution_top.o: ${SRC_PATH}/conv/src/xi_convolution_top.cpp
  ${CC} ${SDSFLAGS} ${CFLAGS} ${CONV_FLAGS} -sds-hw XiConvolutionTop ${SRC_PATH}/conv/src/xi_convolution_top.cpp -clkid ${CLOCK_ID} \
    -hls-tcl ${CONV_SCRIPTS_PATH}/config_core.tcl -sds-end -fPIC $< -o $@

  pooling_layer_dp_2xio_top.o: ${SRC_PATH}/pool/src/pooling_layer_dp_2xio_top.cpp
    ${CC} ${SDSFLAGS} ${CFLAGS} -sds-hw PoolTop ${SRC_PATH}/pool/src/pooling_layer_dp_2xio_top.cpp -clkid ${CLOCK_ID} -sds-end -fPIC $< -o $@

  xi_deconv_top.o: ${SRC_PATH}/deconv/src/xi_deconv_top.cpp
    ${CC} ${SDSFLAGS} ${CFLAGS} -sds-hw XiDeconvTop ${SRC_PATH}/deconv/src/xi_deconv_top.cpp -clkid ${CLOCK_ID} -sds-end -fPIC $< -o $@
  ```

  - After:
    - Remove "-sds-hw *** -sds-end"

  ```Makefile
  xi_convolution_top.o: ${SRC_PATH}/conv/src/xi_convolution_top.cpp
      ${CC} ${SDSFLAGS} ${CFLAGS} ${CONV_FLAGS}  -fPIC $< -o $@

  pooling_layer_dp_2xio_top.o: ${SRC_PATH}/pool/src/pooling_layer_dp_2xio_top.cpp
      ${CC} ${SDSFLAGS} ${CFLAGS}  -fPIC $< -o $@

  xi_deconv_top.o: ${SRC_PATH}/deconv/src/xi_deconv_top.cpp
        ${CC} ${SDSFLAGS} ${CFLAGS}  -fPIC $< -o $@
  ```

- Build

  - See the previous section

- Run

  - It takes >6Hr (!) to run AlexNet example

  ```bash
  root@ultra96:~/chaidnn# ./alexnet.elf Xilinx 8 images/camel.jpg images/fish.jpg
  [INFOx] Network Path : models/AlexNet/8Bit

  ...

  [PERFM] Performance with Batching : 0.008932 Images/second
  [INFOx] Unapack output data

  ...
  ```
