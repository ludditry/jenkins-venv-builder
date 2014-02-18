#!/bin/bash

set -e

function on_exit() {
    [ -e ${VENV}.tar.gz ] && rm ${VENV}.tar.gz
    [ -e ${VENV} ] && rm -rf ${VENV}
}

REQUIREMENTS=${1:-swift-trunk}.txt
if [ ! -e "${REQUIREMENTS}" ]; then
    echo Cannot find file ${REQUIREMENTS}
    exit 1
fi

VENV=swift-$(date +%Y%m%d%H%M)

trap on_exit exit

virtualenv ${VENV}
. ${VENV}/bin/activate
pip install -r ${REQUIREMENTS}

# walk through and fix up the shebang
for target in ${VENV}/bin/*; do
    if [ -x "${target}" ] && [[ $(file "${target}") =~ "ython script" ]]; then
        echo -e '1s/^.*$/#!\/usr\/bin\/env python\nw\nq\n' | ed "${target}"
    fi
done

tar -cvzf ${VENV}.tar.gz ${VENV}
mv ${VENV}.tar.gz /var/www/
