#
# This file is the dnndk recipe.
#

SUMMARY = "Simple dnndk application"
SECTION = "PETALINUX/apps"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

DEPENDS += "opencv"

SRC_URI = " \
	file://bin/dexplorer \
	file://bin/dsight \
	file://lib/echarts.js \
	file://lib/libdsight.a \
	file://lib/libhineon.so \
	file://lib/libn2cube.so \
	file://lib/libdputils.so.3.3 \
	"

S = "${WORKDIR}"

TARGET_CC_ARCH += "${LDFLAGS}"

do_install() {
	     install -d ${D}/${bindir}
	     install -m 0755 ${S}/bin/dexplorer          ${D}/${bindir}
	     install -m 0755 ${S}/bin/dsight             ${D}/${bindir}

	     install -d ${D}/${libdir}
	     install -m 0644 ${S}/lib/echarts.js         ${D}/${libdir}
	     install -m 0644 ${S}/lib/libdsight.a        ${D}/${libdir}
	     install -m 0644 ${S}/lib/libhineon.so       ${D}/${libdir}
	     install -m 0644 ${S}/lib/libn2cube.so       ${D}/${libdir}
	     install -m 0644 ${S}/lib/libdputils.so.3.3  ${D}/${libdir}/libdputils.so

	     install -d ${D}/usr/local/lib
             cd ${D}/usr/local/lib
             ln -s ../../lib/libn2cube.so libn2cube.so
}

FILES_${PN} += " \
	${bindir} \
	${libdir} \
	/usr/local/lib \
	"
FILES_SOLIBSDEV = ""
INSANE_SKIP_${PN} += "dev-so"
INSANE_SKIP_${PN} += "ldflags"
INSANE_SKIP_${PN}-dev += "ldflags"
