#!/bin/bash

echo "The script will clean all repositories cloned in the repo folder (except the Linux one that will only be cleaned from pending modification and local/remote github branches in order to speed up further cloning)"

# Manual cleaning of linux repo to speed up the cleaning
pushd repo/fusion_seacloud_linux.git
git checkout SCR1
git branch -D github_publication_SC4500
git branch -D github_publication_SC4200
git remote remove github
popd

mv repo/fusion_seacloud_linux.git repo/temporary_hidden_linux

rm -rf repo/fusion*

mv repo/temporary_hidden_linux repo/fusion_seacloud_linux.git
