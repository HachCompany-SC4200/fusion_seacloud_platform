#!/bin/bash

# Stop on error
set -e

echo "New commits ready to be pushed"
find repo/* -maxdepth 0 -type d -exec sh -c 'cd {}; pwd; git log --pretty=oneline  origin/github_publication_SC4200^^.. ; echo ' \;

echo "Check the listed commits. That is the last chance to cancel with Ctrl+C if needed"
read -p "Press entrer to push changes to stash... "

echo "Push all repositories to stash"
find repo/* -maxdepth 0 -type d -exec sh -c "cd {}; pwd ; git push origin github_publication_SC4200; echo " \;

echo "You can now check on stash that the commits content is OK. That is the last chance to cancel with Ctrl+C if needed"
read -p "Press entrer to push github_publication_SC4200 branch to github public repository... "

echo "Push all repositories to github (require a proper github user linked to current ssh key)"
find repo/* -maxdepth 0 -type d -exec sh -c "cd {}; pwd ; git push github github_publication_SC4200; echo " \;


