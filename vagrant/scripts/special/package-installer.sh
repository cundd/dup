#!/bin/bash
set -o nounset
set -o errexit

DUP_LIB_PATH="${DUP_LIB_PATH:-$(dirname "$0")/../../../shell/lib.sh}";
source "$DUP_LIB_PATH";

function main() {
    local status;
    echo "Request install packages $@";
    set +e;
    duplib::package_install $@;
    status=$?;
    set -e;
    
    if [[ $status -eq 103 ]]; then
        return 1;
    fi
}

main $@