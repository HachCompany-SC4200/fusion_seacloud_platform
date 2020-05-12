#!/bin/bash

# Stop on error
set -e

echo "Push all repositories to stash"
find repo/* -maxdepth 0 -type d -exec sh -c "cd {}; pwd ; git push origin github_publication_SC4200; echo " \;

echo "Push all repositories to github (require a proper github user linked to current ssh key)"
find repo/* -maxdepth 0 -type d -exec sh -c "cd {}; pwd ; git push github github_publication_SC4200; echo " \;


