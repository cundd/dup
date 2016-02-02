#!/bin/bash
#
# Plugin to make SSH connections
set -o nounset
set -o errexit

# --------------------------------------------------------
# Commands
# --------------------------------------------------------

# Connect to the Vagrant machine through SSH
function dupcli::ssh::connect() {
    if [[ $(dupcli::is_guest) == "yes" ]]; then
        duplib::fatal_error "This machine appears to be the guest machine";
    elif [[ -e "$DUP_BASE/.vagrant/machines/default/virtualbox/id" ]]; then
        dupcli::_ssh::vagrant::connect "$@";
    else
        duplib::fatal_error "No supported way to connect found";
    fi
}

# Execute a command on the Vagrant machine through SSH
function dupcli::ssh::execute() {
    if [ $# -eq 0 ]; then
        duplib::fatal_error "Missing argument 1 (command)";
    fi

    if [[ $(dupcli::is_guest) == "yes" ]]; then
        duplib::fatal_error "This machine appears to be the guest machine";
    elif [[ -e "$DUP_BASE/.vagrant/machines/default/virtualbox/id" ]]; then
        dupcli::_ssh::vagrant::execute "$@";
    else
        duplib::fatal_error "No supported way to connect found";
    fi
}

# Alias for ssh::execute
function dupcli::ssh::exec() {
    dupcli::ssh::execute "$@";
}


# --------------------------------------------------------
# Vagrant adapter
# --------------------------------------------------------
function dupcli::_ssh::vagrant::user_and_host() {
    echo "vagrant@127.0.0.1";
}

function dupcli::_ssh::vagrant::options() {
    echo "" \
        "-o Compression=yes -o DSAAuthentication=yes -o LogLevel=FATAL " \
        "-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null " \
        "-o IdentitiesOnly=yes -i $DUP_BASE/.vagrant/machines/default/virtualbox/private_key" \
        "-o ConnectTimeout=1 -o ConnectionAttempts=1";
}

function dupcli::_ssh::vagrant::port() {
    VBoxManage showvminfo "$(cat "$DUP_BASE/.vagrant/machines/default/virtualbox/id")" --machinereadable |\
        grep "Forwarding(\d)=\"ssh,tcp,127\.0\.0\.1"|\
        awk -F, '{print $4}';
}

function dupcli::_ssh::vagrant::connect() {
    local user_and_server=$(dupcli::_ssh::vagrant::user_and_host);
    local port=$(dupcli::_ssh::vagrant::port);
    local options=$(dupcli::_ssh::vagrant::options);

    local verbose='';
    if [[ $(duplib::get_option_is_set "-v" $@) == "true" ]]; then
        verbose="-v";
    elif [[ $(duplib::get_option_is_set "-vv" $@) == "true" ]]; then
        verbose="-vv";
    elif [[ $(duplib::get_option_is_set "-vvv" $@) == "true" ]]; then
        verbose="-vvv";
    fi

    ssh $verbose $options -p "$port" "$user_and_server" || {
         # Check if a timeout occurred
         if [ $? -eq 255 ]; then
             echo "Try to connect through vagrant binary";
             dupcli::_vagrant::ssh;
         else
             return 1;
         fi
    }
}

function dupcli::_ssh::vagrant::execute() {
    local user_and_server=$(dupcli::_ssh::vagrant::user_and_host);
    local port=$(dupcli::_ssh::vagrant::port);
    local options=$(dupcli::_ssh::vagrant::options);

    local verbose='';
    if [[ $(duplib::get_option_is_set "-v" $@) == "true" ]]; then
        verbose="-v";
    elif [[ $(duplib::get_option_is_set "-vv" $@) == "true" ]]; then
        verbose="-vv";
    elif [[ $(duplib::get_option_is_set "-vvv" $@) == "true" ]]; then
        verbose="-vvv";
    fi

    ssh $verbose $options -p "$port" "$user_and_server" "bash -l -c '$@'" || {
        # Check if a timeout occurred
        if [ $? -eq 255 ]; then
            echo "Try to connect through vagrant binary";
            dupcli::_vagrant::ssh -c "$@";
        else
            return 1;
        fi
    }
}
