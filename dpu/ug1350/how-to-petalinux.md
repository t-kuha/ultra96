# How to prepare PetaLinux project

- Create project

```shell-session
$ export PRJ_NAME=petalinux
$ export SRC_DIR=$(pwd)/Edge-AI-Platform-Tutorials/docs/DPU-Integration/reference-files/files

# Create project
$ petalinux-create -t project -n ${PRJ_NAME} --template zynqMP

# Configure project
$ petalinux-config -p ${PRJ_NAME} --get-hw-description=.
```

- Add files

```shell-session
# Add DNNDK prebuilt library
$ petalinux-create -p ${PRJ_NAME} -t apps --template install --name dnndk --enable
$ rm petalinux/project-spec/meta-user/recipes-apps/dnndk/files/dnndk
$ cp -R Edge-AI-Platform-Tutorials/docs/DPU-Integration/reference-files/files/recipes-apps/dnndk/*
 petalinux/project-spec/meta-user/recipes-apps/dnndk

# Add DPU Kernel module
$ petalinux-create -p ${PRJ_NAME} -t modules --name dpu --enable
$ rm petalinux/project-spec/meta-user/recipes-modules/dpu/files/*
$ cp -R ${SRC_DIR}/recipes-modules/dpu/* petalinux/project-spec/meta-user/recipes-modules/dpu

# Add protobuf
$ mkdir petalinux/project-spec/meta-user/recipes-devtools
$ cp -R Edge-AI-Platform-Tutorials/docs/DPU-Integration/reference-files/files/recipes-devtools/protobuf petalinux/project-spec/meta-user/recipes-devtools

# Add OpenCV (3.1)
$ petalinux-create -p ${PRJ_NAME} -t apps --name opencv --enable
$ rm -r petalinux/project-spec/meta-user/recipes-apps/opencv/files
$ rm petalinux/project-spec/meta-user/recipes-apps/opencv/opencv.bb
$ cp -R Edge-AI-Platform-Tutorials/docs/DPU-Integration/reference-files/files/recipes-support/opencv/* petalinux/project-spec/meta-user/recipes-apps/opencv
```

- Update device tree

```shell-session

```
