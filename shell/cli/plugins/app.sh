#!/bin/bash
#
# Install applications and packages using dup
set -o nounset
set -o errexit

# Install a application using the system's package manager
function dupcli::app::install() {
    if [[ -z ${1+x} ]]; then duplib::error "Please specify at least one package"; return 1; fi;

    duplib::package_install "$@";
}

# Search a application using the system's package manager
function dupcli::app::search() {
    if [[ -z ${1+x} ]]; then duplib::error "Please specify at least one package"; return 1; fi;

    duplib::package_search "$@";
}

# Perform a system upgrade
function dupcli::app::system_upgrade() {
    duplib::system_upgrade "$@";
}
