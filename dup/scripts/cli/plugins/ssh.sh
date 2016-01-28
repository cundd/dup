#!/bin/bash
#
# Plugin to make SSH connections
set -o nounset
set -o errexit

# --------------------------------------------------------
# Commands
# --------------------------------------------------------
function dupcli::ssh::connect() {
    if [[ $(dupcli::is_guest) == "yes" ]]; then
        duplib::fatal_error "This machine appears to be the guest machine";
    elif [[ -e "$DUP_BASE/.vagrant/machines/default/virtualbox/id" ]]; then
        dupcli::_ssh::vagrant_connect "$@";
    else
        duplib::fatal_error "No supported way to connect found";
    fi
}

function dupcli::ssh::execute() {
    if [ $# -eq 0 ]; then
        duplib::fatal_error "Missing argument 1 (command)";
    fi

    if [[ $(dupcli::is_guest) == "yes" ]]; then
        duplib::fatal_error "This machine appears to be the guest machine";
    elif [[ -e "$DUP_BASE/.vagrant/machines/default/virtualbox/id" ]]; then
        dupcli::_ssh::vagrant_execute "$@";
    else
        duplib::fatal_error "No supported way to connect found";
    fi
}

function dupcli::ssh::exec() {
    dupcli::ssh::execute "$@";
}


# --------------------------------------------------------
# Helper methods
# --------------------------------------------------------
function dupcli::_ssh::get_vagrant_user_and_host() {
    echo "vagrant@127.0.0.1";
}

function dupcli::_ssh::vagrant_get_port() {
    VBoxManage showvminfo "$(cat "$DUP_BASE/.vagrant/machines/default/virtualbox/id")" --machinereadable |\
        grep "Forwarding(\d)=\"ssh,tcp,127\.0\.0\.1"|\
        awk -F, '{print $4}';
}

function dupcli::_ssh::vagrant_connect() {
    local user_and_server=$(dupcli::_ssh::get_vagrant_user_and_host);
    local port=$(dupcli::_ssh::vagrant_get_port);

    local verbose='';
    if [[ $(duplib::get_option_is_set "-v" $@) == "true" ]]; then
        verbose="-v";
    elif [[ $(duplib::get_option_is_set "-vv" $@) == "true" ]]; then
        verbose="-vv";
    elif [[ $(duplib::get_option_is_set "-vvv" $@) == "true" ]]; then
        verbose="-vvv";
    fi

    ssh $verbose -o ConnectTimeout=1 -o ConnectionAttempts=1 -p "$port" "$user_and_server" || {
         # Check if a timeout occurred
         if [ $? -eq 255 ]; then
             echo "Try to connect through vagrant binary";
             dupcli::_vagrant::ssh;
         else
             return 1;
         fi
    }
}

function dupcli::_ssh::vagrant_execute() {
    local user_and_server=$(dupcli::_ssh::get_vagrant_user_and_host);
    local port=$(dupcli::_ssh::vagrant_get_port);

    local verbose='';
    if [[ $(duplib::get_option_is_set "-v" $@) == "true" ]]; then
        verbose="-v";
    elif [[ $(duplib::get_option_is_set "-vv" $@) == "true" ]]; then
        verbose="-vv";
    elif [[ $(duplib::get_option_is_set "-vvv" $@) == "true" ]]; then
        verbose="-vvv";
    fi

    ssh $verbose -o ConnectTimeout=1 -o ConnectionAttempts=1 -p "$port" "$user_and_server" "bash -l -c '$@'" || {
        # Check if a timeout occurred
        if [ $? -eq 255 ]; then
            echo "Try to connect through vagrant binary";
            dupcli::_vagrant::ssh -c "$@";
        else
            return 1;
        fi
    }
}
