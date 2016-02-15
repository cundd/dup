#!/bin/bash
set -o nounset
set -o errexit
set -e

MAGENTO_SETUP="${MAGENTO_SETUP:-false}";

function _download_and_install() {
    if [[ -z ${1+x} ]]; then echo "Missing argument 1 (url)"; return 1; fi;
    if [[ -z ${2+x} ]]; then echo "Missing argument 2 (program_name)"; return 1; fi;

    local cmd="";
    local url="$1";
    local bin_name="$2";

    local bin_directory="$HOME/bin";
    local bin_path="$bin_directory/$bin_name";

    if [[ -e "$bin_path" ]]; then
        echo "$bin_name already installed";
        return 0;
    fi

    echo "Installing $bin_name from $url";

    if [[ ! -e "$bin_directory" ]]; then
        mkdir "$bin_directory";
    fi

    if hash curl 2>/dev/null; then
        cmd="curl -o $bin_path -sS -L $url"
    elif hash wget 2>/dev/null ; then
        cmd="wget -q --no-check-certificate -O $bin_path $url"
    else
       >&2 echo "You need to have curl or wget installed.";
       return 1;
    fi

    $cmd;
    chmod +x "$bin_path";
}

function install_n98-magerun() {
    _download_and_install "https://files.magerun.net/n98-magerun.phar" "n98-magerun.phar";
}

function install_modman() {
    _download_and_install "https://raw.githubusercontent.com/colinmollenhour/modman/master/modman" "modman";
}

function main() {
    if [[ "$MAGENTO_SETUP" == "true" ]]; then
        install_n98-magerun;
        install_modman;
    fi
}

main "$@";
