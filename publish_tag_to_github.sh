#!/bin/bash

# Stop on error
set -e

# check number of parameters
if [ $# -ne 2 ]
then
	echo "This script publish a specific tag to github"
	echo
	echo "Syntax: $0 <tag to publish> <message used for the corresponding commit>"
	echo "e.g.: $0 release/MSM_r2018_4 'SC4200 R2018.4'"
	exit -1
fi

tag=$1
message=$2

VIRTUAL_ENV_PATH=$(mktemp -d)

pushd github_publication > /dev/null

./initialize_venv.sh ${VIRTUAL_ENV_PATH}

source ${VIRTUAL_ENV_PATH}/bin/activate

./prepare_repositories_for_publication.py "${tag}" "${message}"

./publish_repositories.sh

popd > /dev/null

echo "Clean virtual environment"
deactivate
rm -r ${VIRTUAL_ENV_PATH}
