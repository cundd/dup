#!/bin/bash
set -o nounset
set -o errexit
set -e

: ${PUPPET_SETUP="false"}

#BINARY_TARGET_PATH="${BINARY_TARGET_PATH:-/usr/local/bin/sassc}";

DUP_LIB_PATH="${DUP_LIB_PATH:-$(dirname "$0")/../../../shell/lib.sh}";
source "$DUP_LIB_PATH";

function install() {
    set -e;
    DUP_LIB_PACKAGE_NONINTERACTIVE="true" duplib::package_install "ruby";

    gem install puppet --no-ri;
    set +e;
}

function post_install() {
    getent group puppet &>/dev/null || addgroup -g 52 -S puppet;
    getent passwd puppet &>/dev/null || adduser -s /usr/bin/nologin -u 52 -D -S -h /var/lib/puppet puppet puppet;
}

# function pre_install() {
#
# }

function main() {
    if [[ "$PUPPET_SETUP" == "true" ]]; then
        # pre_install;
        install;
        post_install;

    fi
}

main $@
