#!/bin/bash
set -o nounset
#set -o errexit

TYPO3_INSTALL="${TYPO3_INSTALL:-false}";
TYPO3_CLIENT_INSTALL="${TYPO3_CLIENT_INSTALL:-false}";
TYPO3_DOWNLOAD_FORCE="${TYPO3_DOWNLOAD_FORCE:-false}";

function detectDocumentRoot() {
    echo $(grep -hir '^DocumentRoot' /etc/httpd/|head -n1|awk '/^DocumentRoot/{gsub("\"", ""); print $2}')
}

function detectTYPO3Version() {
    find . -maxdepth 1 -iname 'typo3_src-*' -print|head -n1
}

function installTYPO3() {
    cd `detectDocumentRoot`;
    local typo3_src_archive="typo3_src.tgz";

    if [[ ! -e `detectTYPO3Version` ]] || [[ "$TYPO3_DOWNLOAD_FORCE" == "true" ]]; then
        echo "Download TYPO3 into "`pwd`;
        curl -s -L -o $typo3_src_archive get.typo3.org/current;
        tar xaf $typo3_src_archive && rm $typo3_src_archive;

        if [[ -h "typo3" ]]; then rm "typo3"; fi
        if [[ -h "index.php" ]]; then rm "index.php"; fi

        ln -s "`detectTYPO3Version`" "typo3_src";
        ln -s "typo3_src/typo3" .;
        ln -s "typo3_src/index.php" .;
    fi

    if [[ ! -e "typo3conf" ]]; then
        touch FIRST_INSTALL;
    fi
}

function bootstrapTYPO3() {
    #git clone http://git.iresults.li/git/iresults/client.git
    if [[ "$TYPO3_CLIENT_INSTALL" == "true" ]]; then
        echo "Install client";
    fi


}

function run() {
    if [[ "$TYPO3_INSTALL" == "true" ]]; then
        installTYPO3;
        bootstrapTYPO3;
    fi
}

run $@
