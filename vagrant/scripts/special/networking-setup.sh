#!/bin/bash
set -o nounset
set -o errexit

DUP_LIB_PATH="${DUP_LIB_PATH:-$(dirname "$0")/../../../shell/lib/duplib.sh}";
source "$DUP_LIB_PATH";

function setup_nameserver() {
    duplib::add_string_to_file_if_not_found "# Add Google DNS" /etc/resolv.conf;
    duplib::add_string_to_file_if_not_found "nameserver 8.8.8.8" /etc/resolv.conf;
    duplib::add_string_to_file_if_not_found "nameserver 8.8.4.4" /etc/resolv.conf;
}

function main() {
    setup_nameserver;
}

main $@
