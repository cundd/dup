#!/bin/bash
set -o nounset
set -o errexit
set -e

: ${PUPPET_SETUP="false"}

#BINARY_TARGET_PATH="${BINARY_TARGET_PATH:-/usr/local/bin/sassc}";

DUP_LIB_PATH="${DUP_LIB_PATH:-$(dirname "$0")/../../../shell/lib/duplib.sh}";
source "$DUP_LIB_PATH";

function install() {
    set -e;
    DUP_LIB_PACKAGE_NONINTERACTIVE="true" duplib::package_install "ruby";

    gem install puppet --no-ri;
    set +e;
}

function post_install() {
    if [[ "$(duplib::detect_linux_distribution)" == "Alpine" ]]; then
        apk update;
        apk add py-pip;
        ln -s "/usr/bin/pip" "/usr/local/bin/pip3";
    fi
    
    # Create user and group
    getent group puppet &>/dev/null || addgroup -g 52 -S puppet;
    getent passwd puppet &>/dev/null || adduser -s /usr/bin/nologin -u 52 -D -S -h /var/lib/puppet puppet puppet;

    # Create base directory structure
    if [[ ! -e "/etc/puppetlabs/puppet/" ]]; then
        mkdir -p "/etc/puppetlabs/puppet/";
        echo "[puppetd]
  server = puppetmaster.local
  runinterval = 3000
  listen = true
  splay = false
  summarize = true" >> "/etc/puppetlabs/puppet/puppet.conf";
        mkdir -p "/etc/puppetlabs/code/environments/production/modules";
        mkdir -p "/etc/puppetlabs/code/environments/production/manifests";

        echo "127.0.0.1 puppetmaster.local" >> /etc/hosts;
    fi

    # Install useradd and such
    if [[ "$(duplib::detect_linux_distribution)" == "Alpine" ]]; then
        duplib::add_string_to_file_if_not_found 'http://nl.alpinelinux.org/alpine/edge/testing' "/etc/apk/repositories";
        apk update;
        apk add shadow;
    fi
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
