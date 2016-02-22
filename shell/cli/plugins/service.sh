#!/bin/bash
set -o nounset
set -o errexit

# Start the given service
function dupcli::service::start() {
    if [[ -z ${1+x} ]]; then dupcli::_core::usage_error "Missing argument 1 (service)" "serviceName"; fi;
    duplib::service_start $@;
}

# Stop the given service
function dupcli::service::stop() {
    if [[ -z ${1+x} ]]; then dupcli::_core::usage_error "Missing argument 1 (service)" "serviceName"; fi;
    duplib::service_stop $@;
}

# Restart the given service
function dupcli::service::restart() {
    if [[ -z ${1+x} ]]; then dupcli::_core::usage_error "Missing argument 1 (service)" "serviceName"; fi;
    duplib::service_restart $@;
}

# Retrieve the status of the given service
function dupcli::service::status() {
    if [[ -z ${1+x} ]]; then dupcli::_core::usage_error "Missing argument 1 (service)" "serviceName"; fi;
    duplib::service_status $@;
}
