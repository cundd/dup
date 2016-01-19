#!/bin/bash
set -o nounset
set -o errexit

function dupcli::_vagrant::check() {
    if ! hash vagrant 2>/dev/null; then
        duplib::error "Vagrant not installed";
        return 1;
    fi
}

function dupcli::vagrant::halt() {
    dupcli::_vagrant::check;
    vagrant halt $@;
}

function dupcli::vagrant::provision() {
    dupcli::_vagrant::check;
    vagrant provision $@;
}

function dupcli::vagrant::ssh() {
    dupcli::_vagrant::check;
    vagrant ssh $@;
}

function dupcli::vagrant::up() {
    dupcli::_vagrant::check;
    vagrant up $@;
}
