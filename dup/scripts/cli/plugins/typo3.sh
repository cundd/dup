#!/bin/bash
set -o nounset
set -o errexit

function dupcli::typo3::download() {
    if [[ -z ${1+x} ]]; then duplib::error "Missing argument 1 (user@server)"; return 1; fi;

    local user_and_server="$1";
    local excludes="--exclude _processed_ --exclude _temp_";

    local dry="";
    if [[ $(duplib::get_option_is_set "-n" $@) == "true" ]]; then
        dry="-n";
    fi

    local progress="";
    if [[ $(duplib::get_option_is_set "--progress" $@) == "true" ]]; then
        progress="--progress";
    fi

    echo "Download typo3conf";
    rsync -zar $progress $dry $excludes "$user_and_server:httpdocs/typo3conf/" "httpdocs/typo3conf/"

    echo "Download fileadmin";
    rsync -zar $progress $dry $excludes "$user_and_server:httpdocs/fileadmin/" "httpdocs/fileadmin/"
}
