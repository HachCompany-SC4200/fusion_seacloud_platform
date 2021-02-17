#!/bin/bash

# From .repo/manifests, go back to base folder fusion_seacloud_platform
pushd ../.. > /dev/null

# Export environment variables
SOURCE_OUTPUT=${PWD}/source_output
source ./export &> ${SOURCE_OUTPUT} || cat ${SOURCE_OUTPUT}
rm ${SOURCE_OUTPUT}; unset SOURCE_OUTPUT

# Launch bitbake to clean intermediate artifacts
time bitbake -k -f cleanall world 2>&1

popd > /dev/null
