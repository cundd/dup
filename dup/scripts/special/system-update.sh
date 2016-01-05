#!/bin/bash
set -o nounset
set -o errexit

function update-with-pacman() {
    # System upgrade
    pacman -Syu --noconfirm;

    # Remove orphans
    if [[ "$(pacman -Qtdq)" != "" ]]; then
        pacman -Rns --noconfirm $(pacman -Qtdq);
    fi

    # Remove cache
    pacman -Sc --noconfirm;
}

function update-with-apk() {
    >&2 echo "Not implemented yet";
}


function update() {
    if hash pacman 2>/dev/null; then
        update-with-pacman;
    elif hash apk 2>/dev/null; then
        update-with-apk;
    else
        >&2 echo "No matching updater found";
    fi
}

update;
