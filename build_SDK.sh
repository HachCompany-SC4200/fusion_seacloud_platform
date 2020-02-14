# from .repo/manifests, go back to base folder fusion_seacloud_platform
cd ../..

#export environment variables
source ./export

# launch bitbake to build OS artefacts
bitbake console-seacloud-image -c populate_sdk

