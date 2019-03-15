#!/bin/sh
# Copy PetaLinux products for platform creation

PFM_FILE_DIR=pfm_files
PLNX_ROOT=petalinux/u96_base

mkdir -p ${PFM_FILE_DIR}/boot ${PFM_FILE_DIR}/image

# Copy necessary output products
cp ${PLNX_ROOT}/images/linux/u-boot.elf      ${PFM_FILE_DIR}/boot/u-boot.elf
cp ${PLNX_ROOT}/images/linux/zynqmp_fsbl.elf ${PFM_FILE_DIR}/boot/fsbl.elf
cp ${PLNX_ROOT}/images/linux/bl31.elf        ${PFM_FILE_DIR}/boot/bl31.elf
cp ${PLNX_ROOT}/images/linux/pmufw.elf       ${PFM_FILE_DIR}/boot/pmufw.elf
cp ${PFM_FILE_DIR}/regs.init                 ${PFM_FILE_DIR}/boot/regs.init
cp ${PLNX_ROOT}/images/linux/image.ub        ${PFM_FILE_DIR}/image/image.ub
