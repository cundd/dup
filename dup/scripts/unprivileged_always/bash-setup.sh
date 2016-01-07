#!/bin/bash
set -o nounset
set -o errexit

SETUP_BASH="${SETUP_BASH:-true}";

DUP_LIB_PATH="${DUP_LIB_PATH:-$(dirname "$0")/../special/lib.sh}";
source "$DUP_LIB_PATH";

function run() {
    if [[ "$SETUP_BASH" == "true" ]]; then
        add-string-to-file-if-not-found "export DUP_LIB_PATH=$DUP_LIB_PATH" "$HOME/.profile";
        add-string-to-file-if-not-found "export DUP_DOCUMENT_ROOT=$(get-vhost-document-root)" "$HOME/.profile";
        add-string-to-file-if-not-found "export DUP_DB_NAME=$DB_NAME" "$HOME/.profile";
        add-string-to-file-if-not-found "export DUP_DB_USERNAME=$DB_USERNAME" "$HOME/.profile";
        add-string-to-file-if-not-found "export DUP_DB_PASSWORD=$DB_PASSWORD" "$HOME/.profile";
        add-string-to-file-if-not-found 'alias dup-mysql="mysql -u$DUP_DB_USERNAME -p$DUP_DB_PASSWORD -D$DUP_DB_NAME"' "$HOME/.profile";
    fi
}

run $@;
