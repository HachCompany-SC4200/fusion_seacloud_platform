#!/bin/bash


patternTag='^P.*@.*@.*$'

OS_version_file=os_version
FW_version_file=fw_version
package_number_file=package

SHA1_platform=${1}
FW_path=${2}


# Get tag from SHA1 on the repo we are in, that matched a given pattern
# param 1 SHA1 of the commit
# param 2 pattern to find as a regex
# returns the youngest tag (without ^{} suffix if it is an annoted one) that matches the pattern, as string
function GetTagFromCommitSHA1WithPattern {
	echo `git show-ref -d | grep "refs/tags/" | grep $1 | sed -e 's/.*refs\/tags\///' | sed 's/\^{}//g' | grep $2 | tail -1`
}

# Get SHA1 from tag
# param 1 tag to find
# returns the commits pointed by the tag
function GetCommitSHA1FromTag {
	# look for tag in tag list (can be tag or tag^{} in case of annotated tags)
	sha=`git show-ref -d | grep /$1\^{} | cut -d " " -f1`
	if [ -z "$sha" ]
	then
		sha=`git show-ref -d | grep /$1\$ | cut -d " " -f1`
	fi
	echo $sha
}


# check number of parameters
if [ $# -lt 2 ]
then
	echo "This script checkout the good revisions of OS and FW for a revision tag, that should match pattern $patternTag"
	echo 
	echo "Syntax: $0 [platform SHA1] [fusion_fw_common location]"
	echo "e.g.: $0 7013bfe468a83f64f231cbf2fa669dc0b385aba9 ~"
	exit -1
fi
if [ ! -d "$2" ]
then
	echo "The folder specified for firmware path does not exist"
	exit -1
fi





echo "Remove previous version files"
rm -f $OS_version_file $FW_version_file $package_number_file

echo "Check commit SHA1 exists ..."
git checkout $SHA1_platform 2> /dev/null
if [ $? -ne 0 ]
then
	echo "Commit $SHA1_platform does not belong to git repository"
	exit 1
else
	echo "Commit $SHA1_platform belongs to git repository"
fi

#############################
# Extract info for pattern tag

# If the commit that triggered the plan is on a tag that matches pattern, it is an official build. If not, a development one.
echo "Extract info from pattern tag"

# check if the commit used to generate the OS is tagged or not
tagTheCommitIsOn=$(GetTagFromCommitSHA1WithPattern $SHA1_platform $patternTag)

if [ ! -z "$tagTheCommitIsOn" ]
then 
	# commit is on a tag that matches pattern
	echo "Commit is on tag: $tagTheCommitIsOn"

	echo "Tag $tagTheCommitIsOn matches the pattern $patternTag"
	package_number=$(echo $tagTheCommitIsOn | cut -d '@' -f1 |  sed -e 's/P//g')
	OS_version=$(echo $tagTheCommitIsOn | cut -d '@' -f2)
	FW_version=$(echo $tagTheCommitIsOn | cut -d '@' -f3)

	TAG_FW="SeaCloud/$FW_version"

	SHA1_OS=`GetCommitSHA1FromTag $OS_version`
	# if tag not found, take the one pointed by the SHA1 given in parameter
	if [ -z $SHA1_OS ] 
	then 
		echo "No tag $OS_version found for OS, use $SHA1_platform"
		SHA1_OS=$SHA1_platform
	fi
	
	echo "------------------"
	echo "OS version: $OS_version"


	# extract logs from commits done since last tag
	penultTag=`git describe --tags --abbrev=0 $SHA1_OS^`
	echo "Penult tag found: $penultTag"
	logs=`git log --pretty=oneline $penultTag..$SHA1_OS	 | cut -d " " -f2- | xargs -I {} echo "   -" {}`
	lastTagForLogs=$penultTag


else
	SHA1_OS=$SHA1_platform
	TAG_FW="origin/master"
	
	# commit is NOT on a tag that matches pattern
	echo "No tag that matches pattern $patternTag detected on the commit, generate a development version"

	# /etc/issue: version
	echo "Development version (no tag is on the commit)" >> $OS_version_file
	# extract logs from commits done since last tag
	lastTagFromCommit=`git describe --tags --abbrev=0` 
	echo "Last tag from commit: $lastTagFromCommit"
	logs=`git log --pretty=oneline $lastTagFromCommit..$SHA1_platform | cut -d " " -f2- | xargs -I {} echo "   -" {}`
	lastTagForLogs=$lastTagFromCommit

	# development values for versions
	package_number="undefined"
	OS_version="development"
	FW_version="development"
fi

#############################
# Extract OS/FW good revision
echo "Extract OS $SHA1_OS"	

pushd ../.. > /dev/null
repo init -u ssh://git@stash.hach.ewqg.com:7999/fcfw/fusion_seacloud_platform.git -b $SHA1_OS
repo sync -d
popd > /dev/null

pushd $FW_path > /dev/null

git_dir="fusion_fw_common/.git"
if [ -d $git_dir ]; then
    echo "Directory .git found, skip clone, fetch only"
    
else
    echo "No .git directory found, clone repository"
    git clone ssh://git@stash.hach.ewqg.com:7999/fcfw/fusion_fw_common.git 2>&1
fi

cd fusion_fw_common

echo "-------------------"
echo "FW version: $FW_version"
git fetch
git fetch --prune origin +refs/tags/*:refs/tags/*
# get commit SHA1
SHA1_FW=`GetCommitSHA1FromTag $TAG_FW`
#if the tag does not exist, take the master
if [ -z `GetCommitSHA1FromTag $TAG_FW` ] 
then 
	echo "No tag $TAG_FW found for FW, use master"
	SHA1_FW=`GetCommitSHA1FromTag origin/master`
fi
echo "Checkout fusion_fw_common on commit $SHA1_FW"
git checkout $SHA1_FW
git submodule update --init --recursive SeaCloud_spec
popd > /dev/null

#############################
# Build OS informations
echo "-------- OS version information --------" > $OS_version_file
# /etc/issue: version
echo "OS Version: $OS_version" >> $OS_version_file
# /etc/issue: Commit: SHA1
echo "Commit: $SHA1_platform" >> $OS_version_file
# /etc/issue: Logs
echo "Logs since last tag $lastTagForLogs:" >> $OS_version_file
echo "$logs" >> $OS_version_file

#############################
# Build FW informations
echo $FW_version > $FW_version_file

#############################
# Build Package informations
echo $package_number > $package_number_file

#############################
# display versions
echo "Package: $package_number"
echo "OS version: $OS_version"
echo "FW version: $FW_version"



