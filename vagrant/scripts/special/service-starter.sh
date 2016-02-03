#!/bin/bash
set -o nounset
set -o errexit

DUP_LIB_PATH="${DUP_LIB_PATH:-$(dirname "$0")/../../../shell/lib/duplib.sh}";
source "$DUP_LIB_PATH";

if [[ $(duplib::service_status $1) == "down" ]]; then
    duplib::service_start "$@";
fi
