# Setting
set PRJ_DIR     _vivado
set PRJ_NAME    u96_base
set BD_NAME     ${PRJ_NAME}
set SRC_DIR     src
# set XSDK_DIR    sdk
set NUM_JOBS    4
set DSA_OUT_DIR petalinux


# Create project
create_project ${PRJ_NAME} ${PRJ_DIR} -part xczu3eg-sbva484-1-e
set_property board_part em.avnet.com:ultra96v1:part0:1.2 [current_project]

# Create block design
source $SRC_DIR/bd.tcl

# Set top-level source
make_wrapper -files [get_files ${PRJ_DIR}/${PRJ_NAME}.srcs/sources_1/bd/${PRJ_NAME}/${BD_NAME}.bd] -top
add_files -norecurse ${PRJ_DIR}/${PRJ_NAME}.srcs/sources_1/bd/${PRJ_NAME}/hdl/${BD_NAME}_wrapper.v
set_property top ${BD_NAME}_wrapper [current_fileset]
update_compile_order -fileset sources_1

# Generate block design
regenerate_bd_layout
# validate_bd_design
save_bd_design
generate_target all [get_files  ${PRJ_DIR}/${PRJ_NAME}.srcs/sources_1/bd/${PRJ_NAME}/${PRJ_NAME}.bd]

# Create .dsa
file mkdir ${DSA_OUT_DIR}
write_dsa ${DSA_OUT_DIR}/${PRJ_NAME}.dsa
validate_dsa ${DSA_OUT_DIR}/${PRJ_NAME}.dsa

# Finish - close project
close_project
