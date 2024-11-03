#!/bin/sh
#
# Builds APK packages for Alpine Linux. Cannot run as root.
# Usage: doas -u build sh build-packages.sh $ABUILD_WORKING_DIRECTORY $SIGNING_KEY_NAME $ALPINE_APORTS_VERSION
#        $OPENFORTIVM_VPN_VERSION $OPENFORTIVM_CONF_VERSION
#


# Move to build directory
cd $1

# Clone the aports repository
git clone --depth=1 https://gitlab.alpinelinux.org/alpine/aports.git --branch $3 aports

# Create Alpine signing key
mkdir -p .abuild

if [ -z ".abuild/$2.rsa" ] || [ ! -f ".abuild/$2.rsa" ]	|| [ -z ".abuild/$2.rsa.pub" ] || [ ! -f ".abuild/$2.rsa.pub" ]; then
	abuild-keygen -i -a -n
fi

# Create openfortivm-vpn APK
mkdir -p aports/testing/openfortivm-vpn
cd aports/testing/openfortivm-vpn/

cat << EOF > APKBUILD
# Maintainer: Vuhuy Luu <git@shibe.nl>
pkgname=openfortivm-vpn
pkgver=$4
pkgrel=0
pkgdesc="Fortinet compatible PPP+TLS VPN client for openfortivm "
url="https://github.com/vuhuy/openfortivm-vpn"
arch="all"
license="GPL-3.0-only"
depends="ppp-daemon"
makedepends="
	autoconf
	automake
	openssl-dev>3
	"
subpackages="\$pkgname-doc"
source="
	\$pkgname-\$pkgver.tar.gz::https://github.com/vuhuy/openfortivm-vpn/archive/v\$pkgver.tar.gz
	"
options="!check" # No test suite

prepare() {
	default_prepare
	autoreconf -fi
}

build() {
	./configure \\
		--build=\$CBUILD \\
		--host=\$CHOST \\
		--prefix=/usr \\
		--sysconfdir=/etc
	make
}

package() {
	make DESTDIR="\$pkgdir" install
}

EOF

abuild checksum
abuild -r

cd ../../../

# Create openfortivm-conf APK
mkdir -p aports/testing/openfortivm-conf
cd aports/testing/openfortivm-conf/

cat << EOF > APKBUILD
# Maintainer: Vuhuy Luu <git@shibe.nl>
pkgname=openfortivm-conf
pkgver=$5
pkgrel=0
pkgdesc="Setup scripts for openfortivm"
url="https://github.com/vuhuy/openfortivm-conf"
arch="all"
license="MIT"
depends="alpine-conf>=$(echo "$5" | sed 's/_.*//')"
source="
	\$pkgname-\$pkgver.tar.gz::https://github.com/vuhuy/openfortivm-conf/archive/v\$pkgver.tar.gz
	"
options="!check" # No test suite

build() {
	make VERSION=\$pkgver-r\$pkgrel
}

package() {
	make install DESTDIR="\$pkgdir"
}

EOF

abuild checksum
abuild -r

cd ../../../
