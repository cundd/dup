#!/bin/bash
set -o nounset
set -o errexit

function dupcli::vagrant::halt() {
    vagrant halt $@;
}

function dupcli::vagrant::provision() {
    vagrant provision $@;
}

function dupcli::vagrant::ssh() {
    vagrant ssh $@;
}

function dupcli::vagrant::up() {
    vagrant up $@;
}
