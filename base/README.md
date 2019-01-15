# base

- Basic baremetal application project (Blinking of PS LED)

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
