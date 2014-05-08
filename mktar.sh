#!/bin/bash

set -e

BASE_DIR=$(dirname $(readlink -f $0))

function on_exit() {
    [ -e ${VENV}.tar.gz ] && rm ${VENV}.tar.gz
    [ -e ${VENV} ] && rm -rf ${VENV}
}

BUILD_NUMBER=$(printf "%05d" ${BUILD_NUMBER:-$(date +%Y%m%d%H%M)})
REQUIREMENTS=${1:-stable}

if [ ! -e "${REQUIREMENTS}".txt ]; then
    echo Cannot find file ${REQUIREMENTS}.txt
    exit 1
fi

VENV=swift-${BUILD_NUMBER}

trap on_exit exit

virtualenv ${VENV}
. ${VENV}/bin/activate
pip install pip --upgrade

echo "Cementing pip versions"
/bin/bash -x ${BASE_DIR}/rewrite.sh "${REQUIREMENTS}.txt" "${VENV}/definition.txt" "${REQUIREMENTS}"

pip install -r ${VENV}/definition.txt

# walk through and fix up the shebang
for target in ${VENV}/bin/*; do
    if [ -x "${target}" ] && [[ $(file "${target}") =~ "script" ]]; then
        sed -i "${target}" -e '1s_^#!.*python.*_#!/usr/bin/env python_'
    fi
done

tar -cvzf ${VENV}.tar.gz ${VENV}
mkdir -p /var/www/${REQUIREMENTS}
cp ${VENV}.tar.gz /var/www/${REQUIREMENTS}
rm ${VENV}.tar.gz
