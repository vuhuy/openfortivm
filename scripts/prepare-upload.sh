#!/bin/sh
#
# Prepare artifacts (APKs and ISOs) for upload.
# Usage ./prepare-upload.sh $WORKING_DIRECTORY $ABUILD_WORKING_DIRECTORY $RELEASE_VERSION
#


# Move to working directory
cd $1

# Collect packages
mkdir -p publish/apk
find $2/packages -type f -name "*.apk" -exec cp {} publish/apk \;

# Collect images
mkdir -p publish/iso

image_name_ovmt="openfortivm-ovmt-$3-x86_64.iso"
cp $2/iso/openfortivm-ovmt.iso publish/iso/${image_name_ovmt}

image_name_virt="openfortivm-virt-$3-x86_64.iso"
cp $2/iso/openfortivm-virt.iso publish/iso/${image_name_virt}

# Create checksums
cd publish
find . -type f \( -name "*.apk" -o -name "*.iso" \) -exec sh -c '
  for file; do
    sha256sum "${file}" > "${file}.sha256"
  done
' sh {} +
cd ..