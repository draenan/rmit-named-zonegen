#!/bin/bash

for line in $(cat rmit_au_internal.txt); do
    echo $line | grep -q /
    if [ "$?" -eq 1 ]; then
        zone=$line
    else
        mask=${line#*/}
        netaddr=${line%/*}
        octets=$(($mask/8))
        [[ $netaddr =~ ([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})\.[0-9]{1,3} ]]
        case $octets in
            1)
                zone=${BASH_REMATCH[1]}.in-addr.arpa
                ;;
            2)
                zone=${BASH_REMATCH[2]}.${BASH_REMATCH[1]}.in-addr.arpa
                ;;
            3)
                zone=${BASH_REMATCH[3]}.${BASH_REMATCH[2]}.${BASH_REMATCH[1]}.in-addr.arpa
                ;;
            *)
                echo WTF?
                exit 1
                ;;
        esac
    fi

    cat << EOL
zone "$zone" { type slave; masters { 10.84.196.1; }; file "/path/${line%/*}" };
EOL

done
