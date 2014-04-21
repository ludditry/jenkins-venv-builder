#!/bin/bash

set -e
set -u

INFILE=$1
OUTFILE=$2
TYPE=${3:-UNKNOWN}

echo "# Environment type: ${TYPE}" > ${OUTFILE}
echo "# Created on $(date) by ${USER}@$(hostname)" >> ${OUTFILE}

for item in $(cat ${INFILE}); do
    echo -n '.'

    if egrep -q "^git\+https" <<< $item > /dev/null 2>&1; then
        unset path_items
        unset branch_items

        declare -a path_items
        declare -a branch_items

        path=${item/#git+/}
        path_items=( ${path/@/ } )

        repo=${path_items[0]}
        branch_items=( ${path_items[1]/\#/ } )
        branch=${branch_items[0]}
        rest=${branch_items[1]}

        if [ ${#branch} -eq 40 ]; then
            shainfo="as specified"
            sha=${branch}
        else
            unset sha_info
            declare -a sha_info
            sha_info=( $(git ls-remote ${repo} | egrep "refs/[^/]*/${branch}$") )
            sha=${sha_info[0]}
            shainfo=${sha_info[1]}
        fi
        
        echo -e "\n# ${item}" >> ${OUTFILE}
        echo "# Using sha ${sha} (${shainfo})" >> ${OUTFILE}
        echo "git+${repo}@${sha}#${rest}" >> ${OUTFILE}
    else
        echo "${item}" >> ${OUTFILE}
    fi
done

echo 

