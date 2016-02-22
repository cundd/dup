#!/bin/bash
#
# Install applications and packages using dup
set -o nounset
set -o errexit

# Install a application using the system's package manager
function dupcli::app::install() {
    if [[ $# -eq 0 ]]; then dupcli::_core::usage_error "Please specify at least one package" "package(s)"; fi;

    duplib::app_install "$@";
}

# Search a application using the system's package manager
function dupcli::app::search() {
    if [[ $# -eq 0 ]]; then dupcli::_core::usage_error "Please specify at least one package" "package(s)"; fi;

    duplib::app_search "$@";
}

# Perform a system upgrade
function dupcli::app::system_upgrade() {
    duplib::system_upgrade "$@";
}
