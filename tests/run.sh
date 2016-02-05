#!/usr/bin/env bash
#
# DUP CLI client binary
#
# This is the main DUP commmand line tool.
# It will also load plugins from dup/scripts/cli/plugins
set -o nounset
set -o errexit

: ${VERBOSE="false"};

FAILURES=0;
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
    duptest::_tput setaf 1;
    >&2 echo "[FAILED] $@";
    duptest::_tput sgr0;

    FAILED="true";
    FAILURES=$((FAILURES + 1));
}

function duptest::pass() {
    duptest::_tput setaf 3;
    echo "[PASSED] $@";
    duptest::_tput sgr0;
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

function duptest::_tput() {
    if hash tput 2>/dev/null; then
        >&2 tput $@;
    fi
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
        duptest::_tput setaf 1;
        >&2 echo "$FAILURES Test(s) failed";
        duptest::_tput sgr0;

        return 1;
    else
        duptest::_tput setaf 3;
        echo "Test(s) passed";
        duptest::_tput sgr0;
        
        return 0;
    fi
}

main $@;
