#!/bin/bash
set -o nounset
set -o errexit

DUP_LIB_PATH="${DUP_LIB_PATH:-$(dirname "$0")/dup/scripts/lib/duplib.sh}";
source "$DUP_LIB_PATH";

function download() {
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


# --------------------------------------------------------
# Helper methods
# --------------------------------------------------------
function print_help() {
    echo "Usage $0 <command> [<args>]

Commands:
    download user@server    downloads fileadmin and typo3conf using rsync
    halt                    stops the vagrant machine
    provision               provisions the vagrant machine
    ssh                     connects to the vagrant machine via SSH
    up                      starts and provisions the vagrant environment
";
}

function main() {
    if [[ -z ${1+x} ]]; then
        print_help;
        return 1;
    fi;

    local subcommand="$1";
    shift;
    case "$subcommand" in
        download)
            download $@;
        ;;
        halt)
            vagrant halt $@
        ;;
        provision)
            vagrant provision $@
        ;;
        ssh)
            vagrant ssh $@
        ;;
        up)
            vagrant up $@
        ;;
        *)
            print_help;
        ;;
    esac
}

main $@;
