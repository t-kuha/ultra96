# ultra96

  - Ultra96 board projects

## Prerequisite

- Get board file for Ultra96 from AVNet's github

```bash
$ git clone https://github.com/Avnet/bdf.git
$ git checkout eba2fd59c2f3ed3dd06b43d72e7620dc069cbd23
```

***

## base

  - Basic project
  
    - Create baremetal application (Blinking of PS LED)
    
  - How to build:

  ```bash
  # Go into the source directory
  $ cd base

  # HW- Launch Vivado shell
  $ vivado -mode batch -source create_vivado_project.tcl

  # SW - Launch xsct
  xsct% source create_boot_bin.tcl
  ```

  - Copy BOOT_standalone.BIN to SD Card and rename it to BOOT.BIN

***

## Reference

- http://zedboard.org/product/ultra96

- https://github.com/ATaylorCEngFIET/Hello_Ultra96
