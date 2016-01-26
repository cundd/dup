#!/bin/bash
set -o nounset
set -o errexit


function dupcli::_log::get_first_existing() {
    if [[ -z ${1+x} ]]; then duplib::error "Please specify at least one path"; return 1; fi;

    for file in "$1"; do
        if [ -e "$file" ]; then
            echo "$file";
            return 0;
        fi
    done

    duplib::error "None of the paths found ($1)";
    return 1;
}

function dupcli::log::http() {
    local directory=$(dupcli::_log::get_first_existing "/var/log/apache2 /var/log/httpd");
    if [ "$directory" == "" ]; then return 1; fi
    tail $* "$directory/access_log";
}

function dupcli::log::http_error() {
    local directory=$(dupcli::_log::get_first_existing "/var/log/apache2 /var/log/httpd");
    if [ "$directory" == "" ]; then return 1; fi
    tail $* "$directory/error_log";
}

function dupcli::log::mysql() {
    local file=$(dupcli::_log::get_first_existing "/var/log/mariadb/mariadb.log /var/log/mysql/mysql.log /var/log/mysql.log");
    if [ "$file" == "" ]; then return 1; fi
    tail $* "$file";
}

function dupcli::log::php_fpm() {
    local file=$(dupcli::_log::get_first_existing "/var/log/php-fpm.log /var/log/php5-fpm.log /var/log/php-fpm/error.log");
    if [ "$file" == "" ]; then return 1; fi
    tail $* "$file";
}
