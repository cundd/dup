#!/bin/bash
set -o nounset

SETUP_SASS="${SETUP_SASS:-false}";
SOURCE_DIRECTORY_PATH="${SOURCE_DIRECTORY_PATH:-sassc-source}";
BINARY_TARGET_PATH="${BINARY_TARGET_PATH:-/usr/local/bin/sassc}";

DUP_LIB_PATH="${DUP_LIB_PATH:-$(dirname "$0")/../special/lib.sh}";
source "$DUP_LIB_PATH";



function install_build_tools() {
    set -e;
    duplib::package_install perl make gcc;
    set +e;
    # apk add perl alpine-sdk
}

function download_sources_sassc() {
    git clone --depth=1 https://github.com/sass/sassc.git "$SOURCE_DIRECTORY_PATH/sassc";
    # cd "$SOURCE_DIRECTORY_PATH/sassc";
    # git submodule init;
    # git submodule update;
    # cd "$SOURCE_DIRECTORY_PATH";
}

function download_sources_libsass() {
    git clone --depth=1 https://github.com/sass/libsass.git "$SOURCE_DIRECTORY_PATH/libsass";
}

function download_sources() {
    echo "Download libsass and sassc";
    echo "This may take a while";
    download_sources_libsass;
    download_sources_sassc;
}

function build() {
    cd "$SOURCE_DIRECTORY_PATH/sassc";

    echo "Build sassc";
    echo "This may take a while";
    export SASS_LIBSASS_PATH="$SOURCE_DIRECTORY_PATH/libsass";
    make;

    cp "bin/sassc" "$BINARY_TARGET_PATH";
}

function main() {
    if [[ "$SETUP_SASS" == "true" ]]; then
        if [[ ! -x $BINARY_TARGET_PATH ]]; then
            echo "Install sass";
            mkdir -p "$SOURCE_DIRECTORY_PATH";
            cd "$SOURCE_DIRECTORY_PATH";
            SOURCE_DIRECTORY_PATH=`pwd`;

            install_build_tools;
            download_sources;
            build;
        else
            echo "sass already installed in $BINARY_TARGET_PATH";
        fi
    fi
}

main $@
