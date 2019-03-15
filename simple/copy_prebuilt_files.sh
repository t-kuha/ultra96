#!/bin/sh
# Copy prebuilt files for SDSoC platform

PFM_FILE_DIR=pfm_files
INIT_PRJ_DIR=_prj_init

mkdir -p ${PFM_FILE_DIR}/prebuilt

# system.bit file should be renamed to bitstream.bit
cp ${INIT_PRJ_DIR}/_sds/p0/vpl/system.bit    ${PFM_FILE_DIR}/prebuilt/bitstream.bit
# system.hdf file should be renamed to <platform>.hdf
cp ${INIT_PRJ_DIR}/_sds/p0/vpl/system.hdf    ${PFM_FILE_DIR}/prebuilt/u96_base.hdf
cp ${INIT_PRJ_DIR}/_sds/.llvm/partitions.xml ${PFM_FILE_DIR}/prebuilt
cp ${INIT_PRJ_DIR}/_sds/.llvm/apsys_0.xml    ${PFM_FILE_DIR}/prebuilt
cp ${INIT_PRJ_DIR}/_sds/swstubs/portinfo.c   ${PFM_FILE_DIR}/prebuilt
cp ${INIT_PRJ_DIR}/_sds/swstubs/portinfo.h   ${PFM_FILE_DIR}/prebuilt
