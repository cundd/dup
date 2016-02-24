#!/bin/bash
#
# Plugin to make SSH connections to the remote
set -o nounset
set -o errexit

# --------------------------------------------------------
# Commands
# --------------------------------------------------------

# Connect to the remote machine through SSH
function dupcli::remote::connect() {
    if [[ $(dupcli::is_guest) == "yes" ]]; then
        duplib::fatal_error "This machine appears to be the guest machine";
    else
        dupcli::_remote::ssh::connect "$@";
    fi
}

# Execute a command on the remote machine through SSH
# $subcommand: The command to execute
function dupcli::remote::execute() {
    if [[ $# -eq 0 ]]; then
        dupcli::_core::usage_error "Missing argument 1 (command)" "command";
    fi

    if [[ $(dupcli::is_guest) == "yes" ]]; then
        duplib::fatal_error "This machine appears to be the guest machine";
    else
        dupcli::_remote::ssh::execute "$@";
    fi
}

# Alias for ssh::execute
function dupcli::remote::exec() {
    dupcli::remote::execute "$@";
}


# --------------------------------------------------------
# Vagrant adapter
# --------------------------------------------------------
function dupcli::_remote::ssh::user_and_host() {
    local host="$(dupcli::config "project.prod.host")";
    if [[ "$host" == "" ]]; then
        duplib::fatal_error "Configuration 'project.prod.host' is not defined";
    fi

    local user="$(dupcli::config "project.prod.user")";
    if [[ "$user" == "" ]]; then
        duplib::fatal_error "Configuration 'project.prod.user' is not defined";
    fi

    echo "$user@$host";
}

function dupcli::_remote::ssh::connect_timeout() {
    echo "1";
}

function dupcli::_remote::ssh::options() {
    # "-i $(dupcli::config "project.prod.ssh.identity")" \
    echo -n "-F $DUP_BASE/resources/cli/plugins/remote/ssh-config ";
    echo -n "-o ConnectTimeout=$(dupcli::_remote::ssh::connect_timeout) ";

    # local directory="$(dupcli::config "project.prod.directory")";
    # if [[ "$directory" != "" ]]; then
    #     echo -n "-o LocalCommand=\"ls\" ";
    # fi
}

function dupcli::_remote::ssh::port() {
    dupcli::config "project.prod.ssh.port";
}

function dupcli::_remote::ssh::connect() {
    local user_and_server=$(dupcli::_remote::ssh::user_and_host);
    local port=$(dupcli::_remote::ssh::port);
    local options=$(dupcli::_remote::ssh::options);

    local verbose='';
    if [[ $(duplib::get_option_is_set "-v" $@) == "true" ]]; then
        verbose="-v";
    elif [[ $(duplib::get_option_is_set "-vv" $@) == "true" ]]; then
        verbose="-vv";
    elif [[ $(duplib::get_option_is_set "-vvv" $@) == "true" ]]; then
        verbose="-vvv";
    fi

    ssh $verbose $options -p "$port" "$user_and_server";
}

function dupcli::_remote::ssh::execute() {
    local user_and_server=$(dupcli::_remote::ssh::user_and_host);
    local port=$(dupcli::_remote::ssh::port);
    local options=$(dupcli::_remote::ssh::options);

    local verbose='';
    if [[ $(duplib::get_option_is_set "-v" $@) == "true" ]]; then
        verbose="-v";
    elif [[ $(duplib::get_option_is_set "-vv" $@) == "true" ]]; then
        verbose="-vv";
    elif [[ $(duplib::get_option_is_set "-vvv" $@) == "true" ]]; then
        verbose="-vvv";
    fi

    ssh $verbose $options -p "$port" "$user_and_server" "bash -l -c '$@'";
}
