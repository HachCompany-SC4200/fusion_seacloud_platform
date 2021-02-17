#!/usr/bin/env bash

# Exit on error
set -e

VIRTUALENV_FOLDER="venv"

# Exit if environment is already present
[ -x "${VIRTUALENV_FOLDER}" ] && ( echo "Virtual environment folder already exists. Remove it if you know what your are doing and try again" ; exit 1 )

echo "Create Python3 virtual environment"
virtualenv -p python3 "${VIRTUALENV_FOLDER}"

source "${VIRTUALENV_FOLDER}/bin/activate"

echo "Install required modules"
# pip install -r requirements.txt can strangly fails due to PATH length limit of #! in shell script
# Use the proposed workaround to call pip through python interpreter (https://github.com/pypa/virtualenv/issues/596#issuecomment-411485104)
python3 -m pip install -r requirements.txt
