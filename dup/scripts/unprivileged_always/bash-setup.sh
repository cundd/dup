#!/bin/bash
set -o nounset
set -o errexit

SETUP_BASH="${SETUP_BASH:-true}";

DUP_LIB_PATH="${DUP_LIB_PATH:-$(dirname "$0")/../special/lib.sh}";
source "$DUP_LIB_PATH";

function run() {
    if [[ "$SETUP_BASH" == "true" ]]; then
        duplib::add_string_to_file_if_not_found "export DUP_LIB_PATH=$DUP_LIB_PATH" "$HOME/.profile";
        duplib::add_string_to_file_if_not_found "export DUP_VHOST_DOCUMENT_ROOT=$(duplib::get_vhost_document_root)" "$HOME/.profile";
        duplib::add_string_to_file_if_not_found "export DB_NAME=$DB_NAME" "$HOME/.profile";
        duplib::add_string_to_file_if_not_found "export DB_USERNAME=$DB_USERNAME" "$HOME/.profile";
        duplib::add_string_to_file_if_not_found "export DB_PASSWORD=$DB_PASSWORD" "$HOME/.profile";
        duplib::add_string_to_file_if_not_found 'alias dup-mysql="mysql -u$DB_USERNAME -p$DB_PASSWORD -D$DB_NAME"' "$HOME/.profile";
    fi
}

run $@;
