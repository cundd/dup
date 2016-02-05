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
    for provisioner in $DUP_CLI_PATH/vagrant/scripts/**/*.sh; do
        duptest::test "bash" "$provisioner";
    done
    return 1
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
