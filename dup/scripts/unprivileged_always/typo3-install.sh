#!/bin/bash
set -o nounset
set -o errexit

TYPO3_INSTALL="${TYPO3_INSTALL:-false}";
TYPO3_CLIENT_INSTALL="${TYPO3_CLIENT_INSTALL:-false}";
TYPO3_CLIENT_BRANCH="${TYPO3_CLIENT_BRANCH:-master}";

TYPO3_DOWNLOAD_FORCE="${TYPO3_DOWNLOAD_FORCE:-false}";

DUP_LIB_PATH="${DUP_LIB_PATH:-$(dirname "$0")/../special/lib.sh}";
source "$DUP_LIB_PATH";

function detect_typo3_version() {
    find . -maxdepth 1 -iname 'typo3_src-*' -print|head -n1
}

function install_typo3() {
    local typo3_src_archive="typo3_src.tgz";

    if [[ ! -e `detect_typo3_version` ]] || [[ "$TYPO3_DOWNLOAD_FORCE" == "true" ]]; then
        echo "Download TYPO3 into "`pwd`;
        curl -s -L -o $typo3_src_archive get.typo3.org/current;
        tar xzf $typo3_src_archive && rm $typo3_src_archive;

        if [[ -h "typo3" ]]; then rm "typo3"; fi
        if [[ -h "index.php" ]]; then rm "index.php"; fi

        ln -s "`detect_typo3_version`" "typo3_src";
        ln -s "typo3_src/typo3" .;
        ln -s "typo3_src/index.php" .;
    fi

    if [[ ! -e "typo3conf" ]]; then
        touch FIRST_INSTALL;
    fi
}

function bootstrap_typo3() {
    if [[ "$TYPO3_CLIENT_INSTALL" == "true" ]];then
        echo "Install client";
        if [[ ! -e "typo3conf/ext/client" ]]; then
            git clone --branch="$TYPO3_CLIENT_BRANCH" https://git.iresults.li/git/iresults/client.git typo3conf/ext/client;
        fi

        RUN_INTERACTIVE="no" bash typo3conf/ext/client/Resources/Private/Scripts/install.sh
    fi
}

function main() {
    cd `duplib::get_vhost_document_root`;
    if [[ "$TYPO3_INSTALL" == "true" ]]; then
        install_typo3;
        bootstrap_typo3;
    fi
}

set +e;
main $@;
set -e;
