# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

DESCRIPTION="A collection of utilities for programming microcontrollers based on the Cypress M8C core, including the PSoC family"
HOMEPAGE="http://m8cutils.sourceforge.net"
SRC_URI="http://m8cutils.sourceforge.net/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

# Tests need some work
RESTRICT="test"

DEPEND="sys-libs/ncurses
	sys-libs/readline"
RDEPEND="${DEPEND}"

src_prepare() {
	sed -i -e "s:-Werror ::" \
		-e "s:\(CFLAGS_COMMON=\)-g:\1${CFLAGS}:" \
		Common.make || die "sed failed"
}

src_test() {
	emake tests || die "tests failed"
}

src_install() {
	emake INSTALL_PREFIX="${D}/usr" install || die "emake install failed"
	dobin misc/reginfo
	dodoc CHANGES README TODO

	for f in */README ; do
		docinto $(dirname ${f}); dodoc ${f} || die
	done

	for e in */example ; do
		insinto /usr/share/doc/${PF}/${e}; doins ${e}/* || die
	done
}
