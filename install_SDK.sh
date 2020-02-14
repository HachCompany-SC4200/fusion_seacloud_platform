
if [ $# -ne 1 ]
then
	echo "Usage: $0 [path where to install SDK]"
	exit 1
fi

# Remove old SDK before installing it again
rm -rf $1

echo $1 | ../../deploy/sdk/angstrom-glibc-x86_64-armv7at2hf-neon-v2016.12-toolchain.sh

