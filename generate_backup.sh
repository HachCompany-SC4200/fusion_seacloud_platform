#!/bin/bash

# This script create an archive of the yocto data (downloads, layers) to be able to rebuild later an image if the sources are not available anymore
# It creates:
# - a md5 footprint of the full download folder to compare it with last full archive and only archive new and modified files
# - an archive of the download folder
# - an archive of the layer folder

RELATIVE_TOPDIR_LOCATION=../..
TOPDIR_LOCATION=$(cd "${RELATIVE_TOPDIR_LOCATION}"; pwd)
BUILD_LOCATION=${TOPDIR_LOCATION}/build

RELATIVE_DOWNLOAD_PATH=$(grep '^DL_DIR' ${BUILD_LOCATION}/conf/local.conf | sed -n 's#DL_DIR.*${TOPDIR}/##p'| sed -n 's#"##p')
RELATIVE_DEPLOY_PATH=$(grep '^DEPLOY_DIR' ${BUILD_LOCATION}/conf/local.conf | sed -n 's#DEPLOY_DIR.*${TOPDIR}/##p'| sed -n 's#"##p')
DOWNLOAD_PATH=${BUILD_LOCATION}/${RELATIVE_DOWNLOAD_PATH}
DEPLOY_PATH=${BUILD_LOCATION}/${RELATIVE_DEPLOY_PATH}
DOWNLOAD_PATH=$(cd "${DOWNLOAD_PATH}"; pwd)
DEPLOY_PATH=$(cd "${DEPLOY_PATH}"; pwd)

FULL_HASH_FILENAME=yocto_downloads_full_hash.txt
INCREMENTAL_HASH_FILENAME=yocto_downloads_incremental_hash.txt
MODIFIED_LIST_FILENAME=incremental_files_to_archive
MODIFIED_LIST_FILEPATH=${DEPLOY_PATH}/${MODIFIED_LIST_FILENAME}
INCREMENTAL_ARCHIVE_FILENAME=yocto_downloads_incremental.tar
FULL_ARCHIVE_FILENAME=yocto_downloads_full.tar
LAYER_ARCHIVE_FILENAME=layers.tar.bz2
LAYER_ARCHIVE_FILEPATH=${DEPLOY_PATH}/${LAYER_ARCHIVE_FILENAME}

# Display script usage help
function usage() {
	echo "This script generates archives of the OS sources so that it can be rebuilt later"
	echo
	echo "  Syntax: $0 <option>"
	echo
	echo "  option:"
	echo "  --full : to create a full archive of the sources in the deploy folder"
	echo "    e.g.: $0 --full"
	echo
	echo "  --inc <full fingerprint file> : to create an incremental archive of the sources in the deploy folder"
	echo "    e.g.: $0 --inc yocto_downloads_full_hash.txt"
}

# Generate a fingerprint of the download folder
# It does and sorts hashes of all files in download folder excluding *.done, directories and internal stash repos
# $1 : download folder path
function build_download_folder_fingerprint {
	# -maxdepth 1 				: limit search to current folder 
	# -not -type d 				: don't list folder
	# -not -name '*.done'			: don't list '*.done' files
	# -not -name 'git2_stash.hach.ewqg.com*': don't list 'git2_stash.hach.ewqg.com*' files
	# -exec md5sum {} +			: pass as many file as possible to the md5sum command to generate MD5 hashes
	# sort					: sort MD5 hashes
	cd "$1"
	find . -maxdepth 1 -not -type d -not -name '*.done' -not -name 'git2_stash.hach.ewqg.com*' -exec md5sum {} + | sort
	cd - > /dev/null
}

# Return a list of modified files
# $1 : last full MD5 finger print 
# $2 : current MD5 finger print
function list_new_or_modified_files {
	# diff "$1" "$2"	: compare files
	# grep '>'		: keep only new or modified files
	# cut -d ' ' -f 4	: use space as separator and keep fourth field -> keep file name
	diff "$1" "$2" | grep '>'| cut -d ' ' -f 4
}

# Create an archive from a list of file
# $1 : reference folder
# $2 : input file list name
# $3 : destination archive name
function archive_file_list {
	cd "$1"
	# -c : create archive
	# -h : follow symlinks
	# -f <archive> : specify output archive filename
	# -T <file> : file contains the list of file to include in the archive
	tar -chf "$3" -T "$2"
	cd - > /dev/null
}

# Archive Yocto files
# $1 : yocto root path
# $2 : archive name
function archive_yocto_files {
	# Create an archive with layers, export and manifests without the git files
	cd "$1"
	# -j : bzip compression
	# -c : create archive
	# -f <archive> : specify output archive filename
	tar -jcf "$2" --exclude=layers/.git/* layers export .repo/manifest*
	cd - > /dev/null
}


# Check parameters
# - full : create a full archive
# - incremental <hash file> : create an incremental archive based on the hash file provided 
if [ "$1" == "--full" -a $# -eq 1 ]
then
    # Do full backup
    HASH_FILEPATH=${DEPLOY_PATH}/${FULL_HASH_FILENAME}
    ARCHIVE_FILEPATH=${DEPLOY_PATH}/${FULL_ARCHIVE_FILENAME}
    REFERENCE_HASH_FILEPATH=/dev/null
elif [ "$1" == "--inc" -a $# -eq 2 ]
then
    # Do incremental backup
    HASH_FILEPATH=${DEPLOY_PATH}/${INCREMENTAL_HASH_FILENAME}
    ARCHIVE_FILEPATH=${DEPLOY_PATH}/${INCREMENTAL_ARCHIVE_FILENAME}
    REFERENCE_HASH_FILEPATH=$(realpath $2)
    
    if [ ! -e "${REFERENCE_HASH_FILEPATH}" ]
    then
	echo "Can't find the hashes of the last full archive (${REFERENCE_HASH_FILEPATH}). Get it from last full archive."
	exit 1
    fi
else
    # Bad options
    usage
    exit -1
fi

echo Download folder path extracted from current Yocto local.conf: ${DOWNLOAD_PATH}
echo Deploy folder path extracted from current Yocto local.conf: ${DEPLOY_PATH}

if [ -e "${ARCHIVE_FILEPATH}" -o -e "${HASH_FILEPATH}" -o -e "${LAYER_ARCHIVE_FILEPATH}" ]
then
    echo "Previous archive or hash are still present. They will be deleted if you don't cancel now!"
    [ -e "${ARCHIVE_FILEPATH}" ] && rm -vi "${ARCHIVE_FILEPATH}"
    [ -e "${HASH_FILEPATH}" ] && rm -vi "${HASH_FILEPATH}"
    [ -e "${LAYER_ARCHIVE_FILEPATH}" ] && rm -vi "${LAYER_ARCHIVE_FILEPATH}"
fi

echo "Generate download folder finger print"
build_download_folder_fingerprint "${DOWNLOAD_PATH}" > "${HASH_FILEPATH}"

echo "Get list of modified files to archive"
list_new_or_modified_files "${REFERENCE_HASH_FILEPATH}" "${HASH_FILEPATH}" > "${MODIFIED_LIST_FILEPATH}"

echo "Create download archive at ${ARCHIVE_FILEPATH}"
archive_file_list "${DOWNLOAD_PATH}" "${MODIFIED_LIST_FILEPATH}" "${ARCHIVE_FILEPATH}"
rm "${MODIFIED_LIST_FILEPATH}"

echo "Create archive of the layers folder at ${LAYER_ARCHIVE_FILEPATH}"
archive_yocto_files "${TOPDIR_LOCATION}" "${LAYER_ARCHIVE_FILEPATH}"
