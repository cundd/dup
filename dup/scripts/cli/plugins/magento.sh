#!/bin/bash
set -o nounset
set -o errexit

function dupcli::magento::download() {
    if [[ -z ${1+x} ]]; then duplib::error "Missing argument 1 (user@server)"; return 1; fi;
    if [[ -z ${2+x} ]]; then duplib::error "Missing argument 2 (remote_base_path)"; return 1; fi;

    local user_and_server="$1";
    local remote_base_path="$2";
    shift 2;
    local excludes='--exclude var --exclude downloader --exclude includes';
    local local_path=`dupcli::_get_httpdocs_directory`;

    echo "Download App";
    duplib::rsync $user_and_server "$remote_base_path/app/" "$local_path/app/" "$excludes" $@;

    echo "Download JavaScript";
    duplib::rsync $user_and_server "$remote_base_path/js/" "$local_path/js/" "$excludes" $@;

    echo "Download Lib";
    duplib::rsync $user_and_server "$remote_base_path/lib/" "$local_path/lib/" "$excludes" $@;

    echo "Download Skin";
    duplib::rsync $user_and_server "$remote_base_path/skin/" "$local_path/skin/" "$excludes" $@;

    echo "Download Shell";
    duplib::rsync $user_and_server "$remote_base_path/shell/" "$local_path/shell/" "$excludes" $@;

    echo "Download error-console";
    duplib::rsync $user_and_server "$remote_base_path/errors/" "$local_path/errors/" "$excludes" $@;

    echo "Download index.php get.php cron.php";
    duplib::rsync $user_and_server "$remote_base_path/index.php" "$local_path/" "$excludes" $@;
    duplib::rsync $user_and_server "$remote_base_path/get.php" "$local_path/" "$excludes" $@;
    duplib::rsync $user_and_server "$remote_base_path/cron.php" "$local_path/" "$excludes" $@;

    echo "Download .htaccess";
    duplib::rsync $user_and_server "$remote_base_path/.htaccess" "$local_path/" "$excludes" $@;

    echo "Download .modman";
    duplib::rsync $user_and_server "$remote_base_path/.modman/" "$local_path/.modman/" "$excludes" $@;
}
