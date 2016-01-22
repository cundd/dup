#!/bin/bash
set -o nounset
set -o errexit

BASH_SETUP="${BASH_SETUP:-true}";

function run() {
    if [[ "$BASH_SETUP" == "true" ]]; then
        if [[ ! -e "/usr/local/bin/dup" ]]; then
            ln -s "/vagrant/dup/cli" "/usr/local/bin/dup";
        fi
    fi
}

run $@;
