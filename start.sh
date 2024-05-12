#!/bin/sh

if [ ${PDNS_LSTREAM_SLEEP}_ == _ ]; then
    echo "no sleep time set"
else
    sleep ${PDNS_LSTREAM_SLEEP}
fi

if [ ${PDNS_LSTREAM_DNS_SERVER}_ == _ ]; then
    echo "no DNS server set"
else
    eval DNS=\$$PDNS_LSTREAM_DNS_SERVER
    echo "$DNS"
    dig @$DNS $PDNS_LSTREAM_DOMAIN ns
fi

/app/lightningstream --config /app/lightningstream.yaml --minimum-pid 200 sync
