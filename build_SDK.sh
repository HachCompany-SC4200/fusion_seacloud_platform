#!/bin/bash

if [ $# -ne 1 ]
then
	echo "Usage: $0 <image name>"
	exit 1
fi

# From .repo/manifests, go back to base folder fusion_seacloud_platform
pushd ../.. > /dev/null

# Export environment variables
SOURCE_OUTPUT=${PWD}/source_output
source ./export &> ${SOURCE_OUTPUT} || cat ${SOURCE_OUTPUT}
rm ${SOURCE_OUTPUT}; unset SOURCE_OUTPUT

# Launch bitbake to build OS SDK
time bitbake $1 -c populate_sdk

popd > /dev/null

./generate_OSS_notices.sh

./update_download_mirror.sh
