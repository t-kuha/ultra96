# led_blink

- Basic baremetal (standalone) application project (Blinking of PS LED)

***

## How to build

```bash
# HW - Launch Vivado shell
$ vivado -mode batch -source create_vivado_project.tcl

# SW - Launch xsct
xsct% source create_boot_bin.tcl
```

## Run

- Copy BOOT.bin to SD Card and power up the board
