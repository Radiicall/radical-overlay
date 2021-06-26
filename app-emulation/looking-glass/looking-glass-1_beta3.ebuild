# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

MY_PN="looking-glass"
MY_PV="${PV//1_beta/B}"
MY_P="looking-glass-B3-0-g2973319bff"

inherit cmake

DESCRIPTION="A low latency KVM FrameRelay implementation for guests with VGA PCI Passthrough"
HOMEPAGE="https://looking-glass.hostfission.com https://github.com/gnif/LookingGlass/"
SRC_URI="https://looking-glass.io/ci/host/source?id=551 -> ${MY_P}.tar.gz"

RESTRICT="mirror"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="debug"

RDEPEND="dev-libs/libconfig:0=
	dev-libs/nettle:=[gmp]
	media-libs/freetype:2
	media-libs/fontconfig:1.0
	media-libs/libsdl2
	media-libs/sdl2-ttf
	virtual/glu"
DEPEND="${RDEPEND}
	app-emulation/spice-protocol"
BDEPEND="virtual/pkgconfig"

S="${WORKDIR}/${MY_P}"

CMAKE_USE_DIR="${S}"/client

src_unpack() {
	einfo "Unpacking ${MY_P}.tar.gz ..."
	tar -xzf "${DISTDIR}/${MY_P}.tar.gz" "${MY_P}" \
		|| die "unpack failed"
}

src_prepare() {
	default

	# Respect FLAGS
	sed -i -e '/CMAKE_C_FLAGS/s/-O3 -march=native //' \
		-e "/git/s/git describe --always --long --dirty --abbrev=10 --tags/echo ${MY_PV}/" \
		client/CMakeLists.txt || die "sed failed for FLAGS and COMMAND"

	if ! use debug ; then
		sed -i '/CMAKE_C_FLAGS/s/-g //' \
		client/CMakeLists.txt || die "sed failed for debug"
	fi

	cmake_src_prepare
}

src_install() {
	einstalldocs

	dobin "${BUILD_DIR}"/looking-glass-client
}
