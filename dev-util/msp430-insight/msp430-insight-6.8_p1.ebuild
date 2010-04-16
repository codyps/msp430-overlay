# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

inherit eutils flag-o-matic

export CTARGET=${CTARGET:-${CHOST}}
if [[ ${CTARGET} == ${CHOST} ]] ; then
	if [[ ${CATEGORY/cross-} != ${CATEGORY} ]] ; then
		export CTARGET=${CATEGORY/cross-}
	fi
fi

MY_P="insight-${PV/_p/-}"

DESCRIPTION="A graphical interface to the GNU debugger"
HOMEPAGE="http://sourceware.org/insight/"
SRC_URI="ftp://sources.redhat.com/pub/insight/releases/${MY_P}.tar.bz2"

LICENSE="GPL-2 LGPL-2"
[[ ${CTARGET} != ${CHOST} ]] \
	&& SLOT="${CTARGET}" \
	|| SLOT="0"
KEYWORDS="~alpha ~amd64 ~ppc ~sparc ~x86"
IUSE="nls"

RDEPEND="sys-libs/ncurses
	x11-libs/libX11"
DEPEND="${RDEPEND}
	nls? ( sys-devel/gettext )"

S="${WORKDIR}/${MY_P}"

src_prepare() {
	epatch "${FILESDIR}"/insight-6.6-DESTDIR.patch
	epatch "${FILESDIR}"/insight-6.6-burn-paths.patch

	cp -r "${FILESDIR}"/msp430-gdb/* "${S}"
	epatch "${FILESDIR}"/${P/_p/-}.patch

	cd "${S}/tk"
	epatch "${FILESDIR}"/tkImgGIF.patch
}

src_configure() {
	append-flags -fno-strict-aliasing # tcl code sucks
	strip-linguas -u bfd/po opcodes/po
	econf \
		--disable-werror \
		$(use_enable nls) \
		--enable-gdbtk \
		--disable-tui \
		--datadir=/usr/share/${PN}
}

src_install() {
	# the tcl-related subdirs are not parallel safe
	emake -j1 DESTDIR="${D}" install || die

	# Don't install docs when building a cross-insight
	if [[ ${CTARGET} == ${CHOST} ]] ; then
		dodoc gdb/gdbtk/{README,TODO}
	fi

	# the gui tcl code does not consider any of the configure
	# options given it ... instead, it requires the path to
	# be /usr/share/redhat/...
	mv "${D}"/usr/share/${PN}/redhat "${D}"/usr/share/ || die

	# scrub all the cruft we dont want
	local x
	cd "${D}"/usr/bin
	for x in * ; do
		[[ ${x} != *insight ]] && rm -f ${x}
	done
	cd "${D}"
	rm -rf usr/{include,man,share/{info,locale,man}}
	rm -rf usr/lib*
}
