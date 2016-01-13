#!/bin/bash
set -o nounset
set -o errexit

DUP_LIB_PATH="${DUP_LIB_PATH:-$(dirname "$0")/../special/lib.sh}";
source "$DUP_LIB_PATH";

function main() {
    echo "Request install packages $@";
    set +e;
    duplib::package_install $@;
    set -e;
}

main $@
