# `openfortivm`
Connect to Fortinet VPNs using [openfortivpn](https://github.com/vuhuy/openfortivm-vpn) running in a virtual machine.

apk update
apk add alpine-sdk alpine-conf syslinux xorriso squashfs-tools grub grub-efi doas

export ABUILD_WORKING_DIRECTORY=/home/build/apk
export ALPINE_RELEASE_VERSION=3.20.2
export ALPINE_APORTS_VERSION=3.20-stable
export OPENFORTIVM_VPN_VERSION=1.22.1_git20241106
export OPENFORTIVM_CONF_VERSION=3.18.1_git20241106

# Set these environment variables to use an existing signing key.
# SIGNING_KEY=<your@email.com-shorthash>
# SIGNING_KEY_RSA = <base64_encoded_private_key>
# SIGNING_KEY = <base64_encoded_public_key>

scripts/prepare-env.sh ${ABUILD_WORKING_DIRECTORY}
doas -u build sh ${ABUILD_WORKING_DIRECTORY}/build-packages.sh ${ABUILD_WORKING_DIRECTORY} keygen ${ALPINE_APORTS_VERSION} ${OPENFORTIVM_VPN_VERSION} ${OPENFORTIVM_CONF_VERSION}
doas -u build sh ${ABUILD_WORKING_DIRECTORY}/build-images.sh ${ABUILD_WORKING_DIRECTORY} ${ALPINE_RELEASE_VERSION}