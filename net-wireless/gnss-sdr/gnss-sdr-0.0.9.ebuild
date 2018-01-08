
EAPI=6

EGIT_REPO_URI="https://github.com/gnss-sdr/gnss-sdr.git"
EGIT_COMMIT="v0.0.9"

inherit git-r3 cmake-utils

DESCRIPTION="GNSS-SDR: an open source GNSS software defined receiver"
HOMEPAGE="http://gnss-sdr.org"
SRC_URI=""

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="generic osmo opencl cuda"

DEPEND="
  dev-cpp/gtest
  dev-cpp/glog
  dev-libs/boost
  net-wireless/gnuradio[uhd]
  >=dev-cpp/gflags-2.1.2
  >=sci-libs/armadillo-4.650.4
  osmo? ( net-wireless/gr-osmosdr[uhd] )
  osmo? ( >=net-libs/libosmo-dsp-0.3 )
  osmo? ( >=net-wireless/gr-osmosdr-0.1.4_p20150730 )
  opencl? ( virtual/opencl )
  cuda? ( dev-util/nvidia-cuda-sdk )
"


src_prepare() {

 	epatch "${FILESDIR}/${P}-volk_gnsssdr_arch_python3.patch"

	# this is ugly but seems to be required
	git clone https://github.com/google/googletest.git googletest
	cd googletest && git checkout tags/release-1.7.0
	eapply_user
}

src_configure() {

	cd googletest
	if [ -f CMakeLists.txt ] ; then
		cmake . && emake || die "emake failed"
	fi
	cd ..


	local mycmakeargs=(
		-DLIBGTEST_DEV_DIR=${S}/googletest
		-DCMAKE_INSTALL_PREFIX=/usr/local
		-DENABLE_OSMOSDR=$(usex osmo)
		-DENABLE_OPENCL=$(usex opencl)
		-DENABLE_CUDA=$(usex cuda)
		-DENABLE_GENERIC_ARCH=$(usex generic)
	)
	cmake-utils_src_configure
}
