#!/bin/sh

rm -rf _vivado
rm -rf .Xil

# SDSoC platform
rm -rf platform_init
rm -rf platform_final

# Initial SDSoC project for prebuilt HW
rm -rf _prj_init

# Files for platform
rm -rf pfm_files/boot
rm -rf pfm_files/image
rm -rf pfm_files/prebuilt

# PetaLinux files
rm -rf petalinux/u96_base/images/
rm -rf petalinux/u96_base/build/

rm -f *.log
rm -f *.jou
rm -f petalinux/*.dsa
