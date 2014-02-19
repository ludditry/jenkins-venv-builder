#!/bin/bash

set -e

function on_exit() {
    [ -e ${VENV}.tar.gz ] && rm ${VENV}.tar.gz
    [ -e ${VENV} ] && rm -rf ${VENV}
}

BUILD_NUMBER=$(printf "%05d" ${BUILD_NUMBER:-$(date +%Y%m%d%H%M)})

REQUIREMENTS=${1:-swift-trunk}.txt
if [ ! -e "${REQUIREMENTS}" ]; then
    echo Cannot find file ${REQUIREMENTS}
    exit 1
fi

VENV=swift-${BUILD_NUMBER}

trap on_exit exit

virtualenv ${VENV}
. ${VENV}/bin/activate
pip install -r ${REQUIREMENTS}

# walk through and fix up the shebang
for target in ${VENV}/bin/*; do
    if [ -x "${target}" ] && [[ $(file "${target}") =~ "script" ]]; then
        sed -i "${target}" -e '1s_^#!.*python$_#!/usr/bin/env python_'
    fi
done

tar -cvzf ${VENV}.tar.gz ${VENV}
cp ${VENV}.tar.gz /var/www/
rm ${VENV}.tar.gz
