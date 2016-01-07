#!/bin/bash
set -o nounset
set -o errexit

function _update-with-pacman() {
    # System upgrade
    pacman -Syu --noconfirm;

    # Remove orphans
    if [[ "$(pacman -Qtdq)" != "" ]]; then
        pacman -Rns --noconfirm $(pacman -Qtdq);
    fi

    # Remove cache
    pacman -Sc --noconfirm;
}

function _update-with-apk() {
    apk update
    apk upgrade

}

function _update-with-yum() {
    >&2 echo "Not implemented yet";
}


function update() {
    if hash pacman 2>/dev/null; then
        _update-with-pacman;
    elif hash apk 2>/dev/null; then
        _update-with-apk;
    elif hash yum 2>/dev/null; then
        _update-with-yum;
    else
        >&2 echo "No matching updater found";
    fi
}

update;
