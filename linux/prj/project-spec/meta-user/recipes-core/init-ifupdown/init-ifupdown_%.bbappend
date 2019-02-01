# init-ifupdown_%.bbappend content

SRC_URI += " \
        file://interfaces \
        "

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

# Overwrite interface file with myinterface file in rootfs
do_install_append() {
	install -m 0644 ${WORKDIR}/interfaces ${D}${sysconfdir}/network/interfaces
}
