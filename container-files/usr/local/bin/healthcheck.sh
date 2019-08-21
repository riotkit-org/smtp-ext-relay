#!/bin/bash

processes=$(ps aux)
required_processes=(postfix saslauthd rsyslogd supervisor)

for name in ${required_processes[@]}; do
    if [[ ! "${processes}" == *"${name}"* ]]; then
        echo " >> ${name} is down"
        exit 1
    fi
done

exit 0
