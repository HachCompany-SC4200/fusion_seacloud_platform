#!/bin/sh

# From .repo/manifests, go back to base folder fusion_seacloud_platform
pushd ../.. > /dev/null

# Export environment variables
SOURCE_OUTPUT=${PWD}/source_output
source ./export &> ${SOURCE_OUTPUT} || cat ${SOURCE_OUTPUT}
rm ${SOURCE_OUTPUT}; unset SOURCE_OUTPUT

# This script update the yocto download mirror with new file present in the download folder
# It must be launched from the build folder
echo "Update the download mirror with new downloaded packages if any"

RELATIVE_DOWNLOAD_PATH=$(grep '^DL_DIR' conf/local.conf | sed -n 's#DL_DIR.*${TOPDIR}/##p'| sed -n 's#"##p')
echo "Download path: ${RELATIVE_DOWNLOAD_PATH}"

RELATIVE_MIRROR_PATH=$(grep '^SOURCE_MIRROR_URL' conf/local.conf | sed -n 's#SOURCE_MIRROR_URL.*${TOPDIR}/##p'| sed -n 's#"##p')
echo "Mirror download path: ${RELATIVE_MIRROR_PATH}"

find ${RELATIVE_DOWNLOAD_PATH} -maxdepth 1  ! -type l ! -name '*.done' ! -type d -exec cp -v {} ${RELATIVE_MIRROR_PATH} \;

popd > /dev/null
