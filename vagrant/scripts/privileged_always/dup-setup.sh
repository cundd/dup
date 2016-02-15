#!/bin/bash
set -o nounset
set -o errexit

BASH_SETUP="${BASH_SETUP:-true}";
DUP_LIB_PATH="${DUP_LIB_PATH:-$(dirname "$0")/../../../shell/lib/duplib.sh}";
source "$DUP_LIB_PATH";

function main() {
    if [[ "$BASH_SETUP" == "true" ]]; then
        if [[ ! -e "/usr/local/bin/dup" ]]; then
            if [[ -h "/usr/local/bin/dup" ]]; then
                duplib::error "Path /usr/local/bin/dup exists but does not point to a valid file";
            else
                ln -s "/vagrant/dup/shell/cli/dup" "/usr/local/bin/dup" || duplib::error "Could not create /usr/local/bin/dup";
            fi
        fi
    fi
}

main "$@";
