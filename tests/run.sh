#!/usr/bin/env bash
#
# DUP CLI client binary
#
# This is the main DUP commmand line tool.
# It will also load plugins from dup/scripts/cli/plugins
set -o nounset
set -o errexit

: ${VERBOSE="false"};

FAILED="false";

# --------------------------------------------------------
# Test cases
# --------------------------------------------------------
function dupcli_provision() {
    dupcli_provision::install_packages;
    dupcli_provision::run;
}

function dupcli_provision::install_packages() {
    local required_packages="git
htop
apache
apache-proxy
graphicsmagick
ghostscript
openssl
php-fpm
php-gd
php-mcrypt
php-intl
php-mysqli
php-pdo_mysql
php-soap
php-opcache
php-json
php-curl
php-xml
php-zip
php-zlib
php-openssl
php-xmlreader
php-ctype
php-calendar
php-phar
php-iconv"

# mysql-server
# mysql-client

    for package in $required_packages; do
        duptest::test "$DUP_BASE/dup/cli" "app::install" "$package" "-y";
    done
}

function dupcli_provision::run() {
    for provisioner in $(find $DUP_CLI_PATH/vagrant/scripts/privileged_once -iname "*.sh"); do
        duptest::test "bash" "$provisioner";
    done
    for provisioner in $(find $DUP_CLI_PATH/vagrant/scripts/privileged_always -iname "*.sh"); do
        duptest::test "bash" "$provisioner";
    done
    for provisioner in $(find $DUP_CLI_PATH/vagrant/scripts/unprivileged_once -iname "*.sh"); do
        duptest::test "bash" "$provisioner";
    done
    for provisioner in $(find $DUP_CLI_PATH/vagrant/scripts/unprivileged_always -iname "*.sh"); do
        duptest::test "bash" "$provisioner";
    done
}

function dupcli_test() {
    "$DUP_BASE/dup/cli" "help";
}

# --------------------------------------------------------
# Helpers
# --------------------------------------------------------
function duptest::fail() {
    >&2 echo "[FAILED] $@";
    FAILED="true";
}

function duptest::pass() {
    echo "[PASSED] $@";
}

function duptest::test() {
    set -e;
    if [[ "$VERBOSE" != "true" ]]; then
        "$@" &> /dev/null && duptest::pass "$@" || duptest::fail "$@";
    else
        "$@" && duptest::pass "$@" || duptest::fail "$@";
    fi
    set +e;
}

function main() {
    # Prepare the environment
    BASE_PATH=`pwd`;
    cd "$(dirname "$0")";
    TEST_BASE=`pwd`;

    export DUP_CLI_PATH="$(dirname "$TEST_BASE")";
    export DUP_BASE="$DUP_CLI_PATH/..";
    export DUP_CACHE_PATH="/tmp/.dup_cache";

    cd $TEST_BASE;

    # Run the tests
    duptest::test dupcli_test;
    dupcli_provision;

    echo "";
    if [[ "$FAILED" != "false" ]]; then
        >&2 echo "Test(s) failed";
        return 1;
    else
        echo "Test(s) passed";
        return 0;
    fi
}

main $@;
