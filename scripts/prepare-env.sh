#!/bin/sh
#
# Prepare Alpine environment to build the openfortivm APK and image.
# Usage ./prepare-env.sh $ABUILD_WORKING_DIRECTORY
#


# Install packages from repository
apk update
apk add alpine-sdk alpine-conf syslinux xorriso squashfs-tools grub grub-efi doas

# Install go
wget https://go.dev/dl/go$2.linux-amd64.tar.gz
tar -C /usr/local -xzf go$2.linux-amd64.tar.gz

# Set up build user and directory
adduser build -G abuild -g "" -h $1 -D
echo "permit nopass :abuild" | tee -a /etc/doas.d/doas.conf
echo "permit nopass root as build" | tee -a /etc/doas.d/doas.conf

# Set up build directory
mkdir -p $1
chown build:abuild $1

# Copy build scripts for build user
cp scripts/build-packages.sh $1/build-packages.sh
cp scripts/build-images.sh $1/build-images.sh
chown -Rf build:abuild $1/*.sh
chmod +x $1/*.sh

# Set signing keys if defined
if [ -n "${SIGNING_KEY}" ] && [ -n "${SIGNING_KEY_RSA}" ] && [ -n "${SIGNING_KEY_RSA_PUB}" ]; then
	mkdir -p ${ABUILD_WORKING_DIRECTORY}/.abuild
	echo -n ${SIGNING_KEY_RSA} | base64 -d > ${ABUILD_WORKING_DIRECTORY}/.abuild/${SIGNING_KEY}.rsa
	echo -n ${SIGNING_KEY_RSA_PUB} | base64 -d > ${ABUILD_WORKING_DIRECTORY}/.abuild/${SIGNING_KEY}.rsa.pub
	echo -n ${SIGNING_KEY_RSA_PUB} | base64 -d > /etc/apk/keys/${SIGNING_KEY}.rsa.pub
	echo "PACKAGER_PRIVKEY=\"${ABUILD_WORKING_DIRECTORY}/.abuild/${SIGNING_KEY}.rsa\"" > ${ABUILD_WORKING_DIRECTORY}/.abuild/abuild.conf
	chown -Rf build:abuild ${ABUILD_WORKING_DIRECTORY}/.abuild
	chmod 2755 ${ABUILD_WORKING_DIRECTORY}/.abuild
	chmod 600 ${ABUILD_WORKING_DIRECTORY}/.abuild/${SIGNING_KEY}.rsa
fi
