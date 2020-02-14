# Seacloud oe-core setup

## Setup of developement environment
----------
### Installation of the prerequisites:

For example, for Ubuntu 16.04 (64-bit), do:
```bash
sudo dpkg --add-architecture i386
sudo apt-get update
sudo apt-get install g++-4.9-multilib
sudo apt-get install curl dosfstools gawk g++-multilib gcc-multilib lib32z1-dev libcrypto++9v5:i386 libcrypto++-dev:i386 liblzo2-dev:i386 libstdc++-4.9-dev:i386 libusb-1.0-0:i386 libusb-1.0-0-dev:i386 uuid-dev:i386

sudo apt-get install texinfo chrpath libsdl1.2-dev


sudo apt-get install repo diffstat

cd /usr/lib; sudo ln -s libcrypto++.so.9.0.0 libcryptopp.so.6
```
For complete and updated information, please refer to Toradex website:
https://developer.toradex.com/knowledge-base/board-support-package/openembedded-(core)#Prerequisites

### Get the repo
To simplify installation we provide a repo manifest which manages the different git repositories
and the used versions. (more on repo: http://code.google.com/p/git-repo/ )

Install the repo bootstrap binary:
```bash
  mkdir ~/bin
  PATH=~/bin:$PATH
  curl http://commondatastorage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
  chmod a+x ~/bin/repo
```
Create a directory for your oe-core setup to live in and clone the meta information.
```bash
  mkdir oe-core
  cd oe-core
  repo init -u ssh://git@stash.hach.ewqg.com:7999/fcfw/fusion_seacloud_platform.git -b master
  repo sync
```
Source the file export to setup the environment. On first invocation this also copies a sample
configuration to build/conf/*.conf.
```bash
  . export
```

More information on Toradex developer website:

  https://developer.toradex.com/knowledge-base/board-support-package/openembedded-(core)

## How to work with the repo
------------
Branches are created under the SeaCloud specific layers repositories(meta-seacloud and meta-seacloud-bsp).

Work is done on the branches. When the work is done, the modifications on the branches are merged into the master branch.

Then it is needed to  generate a manifest from what is currently checked out. to do so:
```bash
 cd .repo/manifests
 ```
 if you have to update your local branch of the repository "SeaCloud-paltform'
 ```bash
 git checkout -b my-branch-name
 ```
 then execute
 ```bash
 repo manifest --suppress-upstream-revision -r -o default_tmp.xml
 cp default_tmp.xml default.xml
 cp default_tmp.xml head-default.xml
 rm default_tmp.xml
 git commit -a -m 'description...'
 git push
 ```



