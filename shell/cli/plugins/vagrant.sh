#!/bin/bash
set -o nounset
set -o errexit

function dupcli::_vagrant::check() {
    if ! hash vagrant 2>/dev/null; then
        duplib::error "Vagrant not installed";
        return 1;
    fi
}

function dupcli::_vagrant::ssh() {
    dupcli::_vagrant::check;
    vagrant ssh "$*";
}

# Dup alias for `vagrant halt`
function dupcli::vagrant::halt() {
    dupcli::_vagrant::check;
    vagrant halt $@;
}

# Dup alias for `vagrant provision`
function dupcli::vagrant::provision() {
    dupcli::_vagrant::check;
    vagrant provision $@;
}

# Dup alias for `vagrant ssh`
function dupcli::vagrant::ssh() {
    dupcli::_vagrant::ssh "$@";
}

# Dup alias for `vagrant ssh`
function dupcli::vagrant::ssh-config() {
    dupcli::_vagrant::check;
    vagrant ssh-config "$@";
}

# Dup alias for `vagrant up`
function dupcli::vagrant::up() {
    dupcli::_vagrant::check;
    vagrant up $@;
}

# Dup alias for `vagrant reload`
function dupcli::vagrant::reload() {
    dupcli::_vagrant::check;
    vagrant reload $@;
}

# Dup alias for `vagrant status`
function dupcli::vagrant::status() {
    dupcli::_vagrant::check;
    vagrant status $@;
}

# Add the VM IP and given domain to /etc/hosts
function dupcli::vagrant::hosts_add() {
    if [[ -z ${1+x} ]]; then duplib::error "Missing argument 1 (domain.local)"; return 1; fi;

    set -e;
    if [ ! -w "/etc/hosts" ]; then
        duplib::error "Hosts file is not writable (use sudo?)";
        exit 1;
    fi

    echo "Adding $(dupcli::config "vagrant.vm.ip") as $1 to /etc/hosts";
    echo "$(dupcli::config "vagrant.vm.ip")  $1" >> /etc/hosts;
}
