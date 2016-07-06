#!/bin/bash
#
# named-zonegen.sh
#
# Queries Infoblox for the list of authoritative zones and then uses it to
# build BIND-style zone statements.
#
# Outputs to STDOUT, redirect as necessary.
#
# NOTE: Next to no error checking, supplied AS-IS, NO WARRANTY, no liability
#       admitted to, etc.
#

GRIDMASTER="infoblox.mgmt.its.rmit.edu.au"
WAPI_VER="1.7.3"
DNS_VIEW="AU%20Internal"
MAX_RESULTS="2500"
MASTERS="10.84.196.1; 10.68.196.1;"
ZONEFILE_PATH="/path"

API_QUERY_URL="https://${GRIDMASTER}/wapi/v${WAPI_VER}/zone_auth?view=${DNS_VIEW}&_max_results=${MAX_RESULTS}&_return_fields=fqdn"
TEMPFILE=$(mktemp)

>&2 echo Querying $GRIDMASTER for list of authoritative DNS zones ...
curl -u $USER -s -k $API_QUERY_URL | awk -F\" '/fqdn/ {print $4}' | sort -n > $TEMPFILE
if [ ! -s "$TEMPFILE" ]; then
    >&2 echo Error occurred.
    rm $TEMPFILE
    exit 1
fi

>&2 echo Generating zone config ...
for line in $(cat $TEMPFILE); do
    [[ $line =~ / ]]
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
            file="${BASH_REMATCH[ $(( ${octets} + 1 - ${i} )) ]}.$file"
        done
    fi

    cat << EOL
zone "$zone" { type slave; masters { $MASTERS }; file "${ZONEFILE_PATH}/$file" };
EOL

done

rm $TEMPFILE
exit
