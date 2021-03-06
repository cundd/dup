#!/bin/bash
set -o nounset
set -o errexit

BASH_SETUP="${BASH_SETUP:-true}";

DUP_LIB_PATH="${DUP_LIB_PATH:-$(dirname "$0")/../../../shell/lib/duplib.sh}";
source "$DUP_LIB_PATH";

function configure-completion() {
    touch "$HOME/.inputrc";
    duplib::add_string_to_file_if_not_found "set completion-ignore-case on" "$HOME/.inputrc";

    duplib::copy_os_specific_file "bash" "bash_profile" "$HOME/.bash_profile";
}

function configure-environment() {
    duplib::add_string_to_file_if_not_found "export DUP_LIB_PATH=$DUP_LIB_PATH" "$HOME/.profile";

    if [[ ! -z ${DB_HOST+x} ]] && [[ ! -z ${DB_NAME+x} ]] && [[ ! -z ${DB_USERNAME+x} ]] && [[ ! -z ${DB_PASSWORD+x} ]]; then
        duplib::add_string_to_file_if_not_found "export DB_HOST=$DB_HOST" "$HOME/.profile";
        duplib::add_string_to_file_if_not_found "export DB_NAME=$DB_NAME" "$HOME/.profile";
        duplib::add_string_to_file_if_not_found "export DB_USERNAME=$DB_USERNAME" "$HOME/.profile";
        duplib::add_string_to_file_if_not_found "export DB_PASSWORD=$DB_PASSWORD" "$HOME/.profile";
        duplib::add_string_to_file_if_not_found 'alias dup-mysql="mysql -h$DB_HOST -u$DB_USERNAME -p$DB_PASSWORD -D$DB_NAME"' "$HOME/.profile";
    fi

    local vhost_document_root="$(duplib::get_vhost_document_root)";
    if [[ -e "$vhost_document_root" ]]; then
        duplib::add_string_to_file_if_not_found "export DUP_VHOST_DOCUMENT_ROOT=$vhost_document_root" "$HOME/.profile";

        # Change to the vhost document root
        duplib::add_string_to_file_if_not_found "cd $vhost_document_root" "$HOME/.profile";
    fi
}

function main() {
    if [[ "$BASH_SETUP" == "true" ]]; then
        configure-environment;
        configure-completion;
    fi
}

main "$@";
