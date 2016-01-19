#!/bin/bash
set -o nounset
set -o errexit

SETUP_BASH="${SETUP_BASH:-true}";

function run() {
    if [[ "$SETUP_BASH" == "true" ]]; then

        if [[ ! -e "/usr/local/bin/vi" ]]; then
            ln -s "/usr/bin/vim" "/usr/local/bin/vi";
        fi
    fi
}

run $@;
