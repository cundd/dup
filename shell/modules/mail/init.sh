#!/bin/bash
set -o nounset
set -o errexit

MAILHOG_SETUP="${mailhog_setup:-false}";
MAILHOG_LOG="${mailhog_log:-/var/log/mailhog.log}";
MAILHOG_BINARY_PATH="${mailhog_binary_path:-"/usr/local/bin/mailhog"}";

DUP_LIB_PATH="${DUP_LIB_PATH:-$(dirname "$0")/../../../shell/lib/duplib.sh}";
source "$DUP_LIB_PATH";

function daemonize() {
    if [[ $# -ne "2" ]]; then
        duplib::fatal_error "Missing arguments command & log";
    fi
    nohup "$1" &> "$2" &
}

function mailhog_latest() {
    curl -s https://api.github.com/repos/mailhog/MailHog/releases/latest|grep "browser_download_url"|grep "linux_amd64"|head -n 1|awk -F'"' '{print $4}';
}

function mailhog_init() {
    # Make sure the binary is installed
    if [[ ! -e "$MAILHOG_BINARY_PATH" ]]; then
        duplib::info "Download MailHog";
        curl -Lo "$MAILHOG_BINARY_PATH" -sS "$(mailhog_latest)";
        chmod +x "$MAILHOG_BINARY_PATH";
    fi

    # Start MailHog
    local pid=$(pgrep "mailhog");
    if [[ "$pid" != "" ]]; then
        duplib::info "Stopping mailhog process $pid";
        kill $pid;
    fi
    duplib::info "Start mailhog";
    daemonize "$MAILHOG_BINARY_PATH" "$MAILHOG_LOG";
}


# MAILHOG_LOG
function main() {
    if [[ "$MAILHOG_SETUP" == "true" ]]; then
        mailhog_init;
    fi
}

main "$@";
