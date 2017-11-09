# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit eutils unpacker

schemadb="schema_sdb_v29.sql"

DESCRIPTION="Bittorrent client that does not require a website to discover content"
HOMEPAGE="https://www.tribler.org/"
# Temporary hack for Release Candidate versions
RC_PV="7.0.0-rc3"
SRC_URI="https://github.com/Tribler/tribler/releases/download/v${RC_PV}/Tribler-v${RC_PV}.tar.xz -> ${P}.tar.xz"

LICENSE="GPL-2 LGPL-2.1+ PSF-2.4 openssl wxWinLL-3.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+vlc"

RDEPEND="
	dev-lang/python:2.7[sqlite]
	dev-python/apsw
	dev-python/backports-functools-lru-cache
	dev-python/cherrypy
	dev-python/configobj
	dev-python/decorator
	dev-python/feedparser
	dev-python/gmpy
	dev-python/leveldb
	dev-python/m2crypto
	dev-python/matplotlib
	dev-python/meliae
	dev-python/netifaces
	dev-python/psutil
	dev-python/pyasn1
	dev-python/pycryptodome
	dev-python/PyQt5[gui,network,svg,widgets]
	dev-python/twisted-core
	dev-python/twisted-web
	dev-python/wxpython:=
	dev-libs/openssl:0[-bindist]
	dev-libs/libsodium
	net-libs/libtorrent-rasterbar[python]
	vlc? (
			media-video/vlc
			media-video/ffmpeg:0
		)"

DEPEND="${RDEPEND}
	app-arch/unzip"

S="${WORKDIR}/${PN}"

src_prepare() {
	## Temporary Release Candidate hack
	epatch "${FILESDIR}/${PN}-7.0.0-log2homedir.patch"
	epatch "${FILESDIR}/${PN}-7.0.0-fix-desktop.patch"
	eapply_user
}

src_compile() { #{ :; }
	python2 setup.py build
}

src_install() {
	echo "Optimizing Python files..."
	python2 setup.py install --root="${S}" --optimize=1

	#Remove the licenses scattered throughout
	rm Tribler/binary-LICENSE-postfix.txt # GPL-2 LGPL-2.1+ PSF-2.4 openssl wxWinLL-3.1

	insinto /usr/share/doc/${P}
	doins LICENSE
	doins README.rst

	# Upstream does not provide a proper install file, so we install it ourself.
	echo "Installing shared files..."

	insinto /usr/share/${PN}
	doins -r Tribler || die "Installation of Tribler failed!"
	doins -r TriblerGUI || die "Installation of TriblerGUI failed!"
	doins logger.conf
	doins run_tribler.py
	doins check_os.py

	insinto /usr/share/${PN}/Tribler
	doins Tribler/${schemadb} || die "Installation of Tribler's DB failed."

	insinto /usr/share/${PN}/twisted
	doins -r twisted

	exeinto /usr/bin
	doexe debian/bin/${PN}

	# Create desktop icon
	insinto /usr/share/applications
	doins Tribler/Main/Build/Ubuntu/tribler.desktop

	insinto /usr/share/pixmaps
	doins Tribler/Main/Build/Ubuntu/tribler.xpm
	doins Tribler/Main/Build/Ubuntu/tribler_big.xpm
}
