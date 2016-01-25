#!/bin/bash
set -o nounset
set -o errexit

BASH_SETUP="${BASH_SETUP:-true}";

function run() {
    if [[ "$BASH_SETUP" == "true" ]]; then

        if [[ ! -e "/usr/local/bin/vi" ]]; then
            ln -s "/usr/bin/vim" "/usr/local/bin/vi";
        fi
    fi
}

run $@;
