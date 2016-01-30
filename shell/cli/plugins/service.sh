#!/bin/bash
set -o nounset
set -o errexit

function dupcli::service::start() {
    if [[ -z ${1+x} ]]; then duplib::error "Missing argument 1 (service)"; return 1; fi;
    duplib::service_start $@;
}

function dupcli::service::stop() {
    if [[ -z ${1+x} ]]; then duplib::error "Missing argument 1 (service)"; return 1; fi;
    duplib::service_stop $@;
}

function dupcli::service::restart() {
    if [[ -z ${1+x} ]]; then duplib::error "Missing argument 1 (service)"; return 1; fi;
    duplib::service_restart $@;
}

function dupcli::service::status() {
    if [[ -z ${1+x} ]]; then duplib::error "Missing argument 1 (service)"; return 1; fi;
    duplib::service_status $@;
}
