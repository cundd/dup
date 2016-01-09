#!/bin/bash
set -o nounset
set -o errexit

function _install_with_pacman() {
    local allPackages=$@;
    pacman -S --noconfirm --needed $allPackages;
}

function _install_with_apk() {
    local allPackages=$@;

    # Replace package names
    allPackages=$(echo $allPackages | sed 's/\bapache\b/apache2/g') # apache => apache2
    allPackages=$(echo $allPackages | sed 's/\bgraphicsmagick\b/imagemagick/g') # graphicsmagick => imagemagick
    echo "allPackages after $allPackages";
    apk add $allPackages;
}

function _install_with_yum() {
    >&2 echo "Not implemented yet";
}


function install() {
    echo "Request install packages $@";
    set +e;
    if hash pacman 2>/dev/null; then
        _install_with_pacman $@;
    elif hash apk 2>/dev/null; then
        _install_with_apk $@;
    elif hash yum 2>/dev/null; then
        _install_with_yum $@;
    else
        >&2 echo "No matching installer found";
    fi
    set -e;
}

install $@
