# Setting
set PRJ_DIR     _vivado
set PRJ_NAME    hw
set BD_NAME     ${PRJ_NAME}
set SRC_DIR     src
# set XSDK_DIR    sdk
set NUM_JOBS    4
set DSA_OUT_DIR petalinux


# Create project
create_project ${PRJ_NAME} ${PRJ_DIR} -part xczu3eg-sbva484-1-e
set_property board_part em.avnet.com:ultra96v1:part0:1.2 [current_project]

# Add constraint file
add_files -fileset constrs_1 -norecurse ${SRC_DIR}/ultra96v1_petalinux.xdc
import_files -fileset constrs_1 ${SRC_DIR}/ultra96v1_petalinux.xdc

# Create block design
source ${SRC_DIR}/bd.tcl

# Set top-level source
make_wrapper -files [get_files ${PRJ_DIR}/${PRJ_NAME}.srcs/sources_1/bd/${PRJ_NAME}/${BD_NAME}.bd] -top
add_files -norecurse ${PRJ_DIR}/${PRJ_NAME}.srcs/sources_1/bd/${PRJ_NAME}/hdl/${BD_NAME}_wrapper.v
set_property top ${BD_NAME}_wrapper [current_fileset]
update_compile_order -fileset sources_1

# Generate block design
regenerate_bd_layout
validate_bd_design
save_bd_design
generate_target all [get_files  ${PRJ_DIR}/${PRJ_NAME}.srcs/sources_1/bd/${PRJ_NAME}/${PRJ_NAME}.bd]

# Generate bitstream
update_compile_order -fileset sources_1

reset_run synth_1
launch_runs synth_1 -jobs ${NUM_JOBS}
wait_on_run synth_1
launch_runs impl_1 -to_step write_bitstream -jobs ${NUM_JOBS}
wait_on_run impl_1

# Report utilization & clock after implementation
open_run impl_1
report_utilization -name utilization_1
report_clocks

# Export .hdf file
write_hwdef -force -file system.hdf

# Finish - close project
close_project
