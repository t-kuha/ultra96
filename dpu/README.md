# DPU

- Use Vivado / PetaLinux 2018.3

## Get source from GitHub

- Clone

```shell-session
$ git clone https://github.com/Xilinx/Edge-AI-Platform-Tutorials.git
```

- Edit _Edge-AI-Platform-Tutorials/docs/DPU-Integration/reference-files/vivado_ to use version 2018.3

- Before

```tcl
set scripts_vivado_version 2018.2
```

- After

```tcl
set scripts_vivado_version 2018.3
```

***

## Build HW in Vivado

```shell-session
$ vivado -mode batch -source create_vivado_project.tcl
```

***

## Build PetaLinux

***

## Build SW (application)


***

## Reference

- [https://github.com/Xilinx/Edge-AI-Platform-Tutorials/blob/master/docs/DPU-Integration/README.md](https://github.com/Xilinx/Edge-AI-Platform-Tutorials/blob/master/docs/DPU-Integration/README.md)