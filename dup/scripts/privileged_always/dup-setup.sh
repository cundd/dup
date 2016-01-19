#!/bin/bash
set -o nounset
set -o errexit

SETUP_BASH="${SETUP_BASH:-true}";

function run() {
    if [[ "$SETUP_BASH" == "true" ]]; then
        if [[ ! -e "/usr/local/bin/dup" ]]; then
            ln -s "/vagrant/dup/cli" "/usr/local/bin/dup";
        fi
    fi
}

run $@;
