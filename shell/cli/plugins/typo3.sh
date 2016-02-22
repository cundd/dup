#!/bin/bash
set -o nounset
set -o errexit

# Download typo3conf and fileadmin from the given remote
function dupcli::typo3::download() {
    if [[ $# -lt 1 ]]; then dupcli::_core::usage_error "Missing argument 1 (user@server)" "user@server"; fi;
    if [[ $# -lt 2 ]]; then dupcli::_core::usage_error "Missing argument 2 (remote_base_path)" "remote_base_path"; fi;

    local user_and_server="$1";
    local remote_base_path="$2";
    shift 2;
    local excludes='--exclude var --exclude downloader --exclude includes';
    local local_path=`dupcli::_webserver::get_host_vhost_document_root`;

    echo "Download typo3conf";
    duplib::rsync $user_and_server "$remote_base_path/typo3conf/" "$local_path/typo3conf/" "$excludes" $@;

    echo "Download fileadmin";
    duplib::rsync $user_and_server "$remote_base_path/fileadmin/" "$local_path/fileadmin/" "$excludes" $@;
}

# Call the TYPO3 cli (on the VM)
function dupcli::typo3::cli() {
    if [[ $(dupcli::is_guest) == "yes" ]]; then
        set +e;
        php "$(dupcli::_webserver::get_host_vhost_document_root)/typo3/cli_dispatch.phpsh" "$@";
    else
        dupcli::ssh::execute "php typo3/cli_dispatch.phpsh $@";
    fi
}

# Call the TYPO3 Extbase cli (on the VM)
function dupcli::typo3::extbase() {
    if [ $# -eq 0 ]; then
        dupcli::typo3::extbase "help";
    else
        if [[ $(dupcli::is_guest) == "yes" ]]; then
            set +e;
            php "$(dupcli::_webserver::get_host_vhost_document_root)/typo3/cli_dispatch.phpsh" "extbase" "$@";
        else
            dupcli::ssh::execute "php typo3/cli_dispatch.phpsh extbase $@";
        fi
    fi
}
