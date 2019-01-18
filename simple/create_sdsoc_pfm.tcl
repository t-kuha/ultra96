# May have to delete existing platform directory

# Platform name
set PFM_NAME    u96_base
set SRC_DIR     pfm_files
set PREBUILT_DATA_DIR   ${SRC_DIR}/prebuilt

# Check whether prebuilt data folder exists
set HAS_PREBUILT [file exists ${PREBUILT_DATA_DIR}]

if { ${HAS_PREBUILT} } then {
    set OUTDIR  platform_final
} else {
    set OUTDIR  platform_init
}


# Create platform
platform create -name ${PFM_NAME} -hw {petalinux/u96_base.dsa} -out ${OUTDIR}
# {platform}


# ----- Standalone -----
sysconfig create -name "standalone" -display-name "standalone" -desc "Standalone / MPSoC" 

sysconfig config -boot {pfm_files/boot}
sysconfig config -bif {pfm_files/sdsoc_standalone.bif}
sysconfig config -readme {pfm_files/generic.readme}

# Use APU core #0
domain create -name {standalone} -os {standalone} -proc {psu_cortexa53_0} -display-name {standalone} -desc "Standalone" -runtime "C++"

# Add prebuilt data
if { ${HAS_PREBUILT} } then {
    domain config -prebuilt-data ${PREBUILT_DATA_DIR}
}

# Generate linker script automatically
::scw::set_lscript_autogen true

platform write


# ----- Linux -----
# Create system configuration
sysconfig create -name "linux" -display-name "linux" -desc "Linux / MPSoC" 

sysconfig config -boot {pfm_files/boot}
sysconfig config -bif {pfm_files/sdsoc_linux.bif}
sysconfig config -readme {pfm_files/generic.readme}

domain create -name {linux} -os {linux} -proc {psu_cortexa53} -display-name {linux} -desc "Linux" -runtime "C++"

# Add prebuilt data
if { ${HAS_PREBUILT} } then {
    domain config -prebuilt-data ${PREBUILT_DATA_DIR}
}

::scw::set_linux_configured true

domain config -image {pfm_files/image}
platform write


# Generate platform
platform generate
