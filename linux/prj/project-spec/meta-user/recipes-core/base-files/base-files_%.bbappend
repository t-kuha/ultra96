#base-files_%.bbappend content

dirs755 += "/media/card"

FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI += " \
	file://TIInit_11.8.32.bts \
	file://wl18xx-fw-4.bin \
	"

do_install_append() {
	# Install wl1831's firmware
	install -d 0644 ${D}${base_libdir}/firmware/ti-connectivity
	install -m 0644 TIInit_11.8.32.bts ${D}${base_libdir}/firmware/ti-connectivity
	install -m 0644 wl18xx-fw-4.bin ${D}${base_libdir}/firmware/ti-connectivity
	
	# Auto-mount boot directory of SD card 
	sed -i '/mmcblk0p1/s/^#//g' ${D}${sysconfdir}/fstab
}
