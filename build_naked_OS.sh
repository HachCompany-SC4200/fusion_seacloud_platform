#!/bin/bash

if [ $# -ne 1 ]
then
	echo "Usage: $0 <image name>"
	exit 1
fi

# From .repo/manifests, go back to base folder fusion_seacloud_platform
pushd ../.. > /dev/null

# Export environment variables
source ./export

# Launch bitbake to build OS image
time bitbake $1

popd > /dev/null

GIT_REVISION_FILE=../../deploy/images/os_commit
echo "Save current git SHA1 and branch into ${GIT_REVISION_FILE}"
git rev-parse HEAD > ${GIT_REVISION_FILE}
git rev-parse --abbrev-ref HEAD >> ${GIT_REVISION_FILE}

./update_download_mirror.sh
