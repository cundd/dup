#!/bin/bash
#
# Install applications and packages using dup
set -o nounset
set -o errexit


function dupcli::app::install() {
    if [[ -z ${1+x} ]]; then duplib::error "Please specify at least one package"; return 1; fi;

    duplib::package_install "$@";
}

function dupcli::app::search() {
    if [[ -z ${1+x} ]]; then duplib::error "Please specify at least one package"; return 1; fi;

    duplib::package_search "$@";
}
