#!/bin/bash
set -o nounset
set -o errexit

function dupcli::magento::download() {
    if [[ -z ${1+x} ]]; then duplib::error "Missing argument 1 (user@server)"; return 1; fi;
    if [[ -z ${2+x} ]]; then duplib::error "Missing argument 2 (remote_base_path)"; return 1; fi;

    cd `dupcli::_get_httpdocs_directory`;

    local user_and_server="$1";
    local remote_base_path="$2";
    shift 2;
    local excludes='--exclude var --exclude downloader --exclude includes';

    echo "Download app";
    duplib::rsync $user_and_server "$remote_base_path/app/" "httpdocs/app/" "$excludes" $@;

    echo "Download JavaScript";
    duplib::rsync $user_and_server "$remote_base_path/js/" "httpdocs/js/" "$excludes" $@;

    echo "Download lib";
    duplib::rsync $user_and_server "$remote_base_path/lib/" "httpdocs/lib/" "$excludes" $@;

    echo "Download Skin";
    duplib::rsync $user_and_server "$remote_base_path/skin/" "httpdocs/skin/" "$excludes" $@;

    echo "Download Shell";
    duplib::rsync $user_and_server "$remote_base_path/shell/" "httpdocs/shell/" "$excludes" $@;

    echo "Download index.php get.php cron.php";
    duplib::rsync $user_and_server "$remote_base_path/index.php" "httpdocs/" "$excludes" $@;
    duplib::rsync $user_and_server "$remote_base_path/get.php" "httpdocs/" "$excludes" $@;
    duplib::rsync $user_and_server "$remote_base_path/cron.php" "httpdocs/" "$excludes" $@;

    echo "Download .htaccess";
    duplib::rsync $user_and_server "$remote_base_path/.htaccess" "httpdocs/" "$excludes" $@;

    echo "Download .modman";
    duplib::rsync $user_and_server "$remote_base_path/.modman/" "httpdocs/.modman/" "$excludes" $@;
}
