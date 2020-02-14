# from .repo/manifests, go back to base folder fusion_seacloud_platform
cd ../..

# Remove build and deploy folders to force a full rebuild
rm -rf build deploy

#export environment variables
source ./export

# Move yocto package download folder into /home/fusion/bamboo-agent-home/xml-data/build-dir so that it is shared between plan
sed -i '/^DL_DIR.*/c\DL_DIR ?= "${TOPDIR}/../../../../../yocto-downloads"' conf/local.conf

#to avoid "the basehash value changed" warning
rm -rf out-glibc/cache

#cleaning
bitbake -c cleansstate console-seacloud-image

#build OS
bitbake console-seacloud-image
