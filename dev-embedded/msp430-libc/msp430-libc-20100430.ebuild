# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

CHOST="msp430"
CTARGET="msp430"

inherit eutils

DESCRIPTION="C library for MSP430 microcontrollers"
HOMEPAGE="http://mspgcc4.sourceforge.net"
SRC_URI="mirror://sourceforge/mspgcc4/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=">=sys-devel/crossdev-0.9.1"
[[ ${CATEGORY/cross-} != ${CATEGORY} ]] \
	&& RDEPEND="!dev-embedded/msp430-libc" \
	|| RDEPEND=""

S="${WORKDIR}"/${P}/src

pkg_setup() {
	ebegin "Checking for msp430-gcc"
	if type -p msp430-gcc > /dev/null ; then
		eend 0
	else
		eend 1

		eerror
		eerror "Failed to locate 'msp430-gcc' in \$PATH. You can install an MSP430 toolchain using:"
		eerror "  $ crossdev -t msp430"
		eerror
		die "MSP430 toolchain not found"
	fi
}

src_prepare() {
	epatch "${FILESDIR}"/${PN}-20100403-makefile.patch
}

src_install() {
	emake PREFIX="${D}/usr" install || die "emake install failed"
	dodoc "${S}"/../doc/devheaders.txt
	newdoc "${S}"/../doc/volatil volatile
}
