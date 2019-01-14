# Setting
set PRJ_DIR     vivado
set PRJ_NAME    u96_base
set BD_NAME     ${PRJ_NAME}
set SRC_DIR     src
set XSDK_DIR    sdk
set NUM_JOBS    4


# Create project
create_project ${PRJ_NAME} ${PRJ_DIR} -part xczu3eg-sbva484-1-e
set_property board_part em.avnet.com:Ultra96v1:part0:1.2 [current_project]

# Add constraint
add_files -fileset constrs_1 -norecurse ${SRC_DIR}/Ultra96_constraints_180318.xdc

# Add IP repo
# set IP_REPOS  [ format "hls/ip vivado-libaray" ] 
# set_property  ip_repo_paths  ${IP_REPOS}  [current_project]
# update_ip_catalog


# Create block design
source $SRC_DIR/${PRJ_NAME}.tcl

# Set top-level source
make_wrapper -files [get_files ${PRJ_DIR}/${PRJ_NAME}.srcs/sources_1/bd/${PRJ_NAME}/${BD_NAME}.bd] -top
add_files -norecurse ${PRJ_DIR}/${PRJ_NAME}.srcs/sources_1/bd/${PRJ_NAME}/hdl/${BD_NAME}_wrapper.v
set_property top ${BD_NAME}_wrapper [current_fileset]
update_compile_order -fileset sources_1

# 
regenerate_bd_layout
validate_bd_design
save_bd_design

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

# Export HW for SDK
file mkdir ${XSDK_DIR}
# Copy bitstream
file copy -force ${PRJ_DIR}/${PRJ_NAME}.runs/impl_1/${PRJ_NAME}_wrapper.sysdef ${XSDK_DIR}/${PRJ_NAME}_wrapper.hdf
# Do not copy bitstream
# write_hwdef -force  -file D:/Users/kuriharat/Documents/google_cloud/zybo_z7_tpg/vivado/zybo_z7_tpg.sdk/zybo_z7_tpg_wrapper.hdf
# launch_sdk -workspace $XSDK_DIR -hwspec $XSDK_DIR/${PRJ_NAME}_wrapper.hdf

# Finish - close project
close_project


# # Execute
# # https://fpga.kice.tokyo/fpga/config-cmd
# if 0 {
#     open_hw
#     connect_hw_server
#     open_hw_target
#     set BITSTREAM  [format "%s" ${PRJ_DIR}/${PRJ_NAME}.runs/impl_1/${PRJ_NAME}_wrapper.bit] 
#     set_property PROGRAM.FILE $BITSTREAM [get_hw_devices xc7z020_1]
#     program_hw_devices [get_hw_devices xc7z020_1]
#     # refresh_hw_device [lindex [get_hw_devices xc7z020_1] 0]

#     close_hw_target
#     disconnect_hw_server
#     close_hw
# }