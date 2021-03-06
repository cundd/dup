#!/bin/bash
set -o nounset
set -o errexit

DUP_LIB_PATH="${DUP_LIB_PATH:-$(dirname "$0")/../../../shell/lib/duplib.sh}";
source "$DUP_LIB_PATH";

: ${DUP_BASE="dup"}

function setup_nameserver() {
    duplib::add_string_to_file_if_not_found "# Add Google DNS" /etc/resolv.conf;
    duplib::add_string_to_file_if_not_found "nameserver 8.8.8.8" /etc/resolv.conf;
    duplib::add_string_to_file_if_not_found "nameserver 8.8.4.4" /etc/resolv.conf;
}

function setup_hosts() {
    mv "$DUP_BASE/.tmp/networking/hosts" /etc/hosts;
    duplib::add_string_to_file_if_not_found "127.0.0.1 $(hostname -s) $(hostname -f)" /etc/hosts;
}

function main() {
    setup_nameserver;
    setup_hosts;
}

main "$@";
