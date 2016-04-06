#!/bin/bash
set -o nounset
set -o errexit

# Download Magento files from the given remote
function dupcli::magento::download() {
    local user_and_server="$(dupcli::_magento::ssh::user_and_host)";
    local remote_base_path="$(dupcli::_magento::ssh::directory)";

    if [[ "$user_and_server" == "@" ]]; then
        if [[ $# -lt 1 ]]; then dupcli::_core::usage_error "Missing argument 1 (user@server)" "user@server remote_base_path"; fi;
        if [[ $# -lt 2 ]]; then dupcli::_core::usage_error "Missing argument 2 (remote_base_path)" "user@server remote_base_path"; fi;

        user_and_server="$1";
        remote_base_path="$2";
        shift 2;
    fi

    local excludes='--exclude var --exclude downloader --exclude includes';
    local local_path=`dupcli::_webserver::get_host_vhost_document_root`;

    echo "Download App";
    duplib::rsync $user_and_server "$remote_base_path/app/" "$local_path/app/" "$excludes" $@;

    echo "Download JavaScript";
    duplib::rsync $user_and_server "$remote_base_path/js/" "$local_path/js/" "$excludes" $@;

    echo "Download Lib";
    duplib::rsync $user_and_server "$remote_base_path/lib/" "$local_path/lib/" "$excludes" $@;

    echo "Download Media";
    duplib::rsync $user_and_server "$remote_base_path/media/" "$local_path/media/" "$excludes --exclude cache --exclude media/tmp/" $@;

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

# Call n98-magerun
function dupcli::magento::n98-magerun() {
    if [[ $(dupcli::is_guest) == "yes" ]]; then
        n98-magerun.phar "$@";
    else
        dupcli::ssh::execute "n98-magerun.phar $@";
    fi
}

# Call modman
function dupcli::magento::modman() {
    if [[ $(dupcli::is_guest) == "yes" ]]; then
        modman "$@";
    else
        dupcli::ssh::execute "modman $@";
    fi
}

# Open Magento system.log
function dupcli::magento::system_log() {
    if [[ $(dupcli::is_guest) == "yes" ]]; then
        tail "$@" "$(dupcli::_webserver::get_guest_vhost_document_root)/var/log/system.log";
    else
        dupcli::ssh::execute tail "$@" "$(dupcli::_webserver::get_guest_vhost_document_root)/var/log/system.log";
    fi
}

function dupcli::_magento::ssh::user_and_host() {
    local host="$(dupcli::config "project.prod.host")";
    local user="$(dupcli::config "project.prod.user")";

    echo "$user@$host";
}

function dupcli::_magento::ssh::directory() {
    dupcli::config "project.prod.directory";
}
