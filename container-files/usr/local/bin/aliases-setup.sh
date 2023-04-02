#!/bin/bash

ALIASES_PATH=${ALIASES_PATH:-/etc/aliases}
touch "${ALIASES_PATH}"

if [[ "${ALIASES}" != "" ]]
then
    IFS=';' read -ra ADDR <<< "$ALIASES"
    for i in "${ADDR[@]}"; do
        if [[ "$(cat ${ALIASES_PATH})" != *"$i"* ]]; then
            echo ">> Adding $i to /etc/aliases"
            echo "$i" >> ${ALIASES_PATH}
        fi
    done

    echo " >> The new /etc/aliases file:"
    cat ${ALIASES_PATH}
fi

echo " >> Regenerating aliases file"
newaliases
