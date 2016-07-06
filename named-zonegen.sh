#!/bin/bash

MASTERS="10.84.196.1; 10.68.196.1;"
FILEPATH="/path"

for line in $(cat rmit_au_internal.txt); do
    echo $line | grep -q /
    if [ "$?" -eq 1 ]; then
        zone="$line"
        file="$line"
    else
        mask="${line#*/}"
        netaddr="${line%/*}"
        octets="$(($mask/8))"
        [[ $netaddr =~ ([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})\.[0-9]{1,3} ]]
        zone="in-addr.arpa"
        file="rev"
        for (( i=1; i<=$octets; i++ )); do
            zone="${BASH_REMATCH[$i]}.$zone"
            file="${BASH_REMATCH[$(($octets + 1 - $i))]}.$file"
        done
    fi

    cat << EOL
zone "$zone" { type slave; masters { $MASTERS }; file "${FILEPATH}/$file" };
EOL

done
