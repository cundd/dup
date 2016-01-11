#!/bin/bash
set -o nounset
set -o errexit

function setup-nameserver() {
    echo "<<NS_SETUP
# Add Google DNS
nameserver 8.8.8.8
nameserver 8.8.4.4
NS_SETUP" >> /etc/resolv.conf;
}

function main() {
    setup-nameserver;
}

main $@
