#!/bin/bash
set -o nounset
set -o errexit

DUP_LIB_PATH="${DUP_LIB_PATH:-$(dirname "$0")/../../../shell/lib/duplib.sh}";
source "$DUP_LIB_PATH";

function main() {
    local status;
    echo "Request install packages $@";
    set +e;
    DUP_LIB_APP_NONINTERACTIVE="true" duplib::app_install $@;
    status=$?;
    set -e;

    if [[ $status -eq 103 ]]; then
        return 1;
    fi
}

main $@
