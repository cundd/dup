#!/bin/bash
set -o nounset
set -o errexit

# Alias for dupcli::mysql::connect
function dupcli::mysql() {
    dupcli::mysql::connect;
}

# Connect to the databank defined in the configuration
function dupcli::mysql::connect() {
    if [ -z ${DB_USERNAME+x} ]; then
        DB_USERNAME='';
    fi
    if [ -z ${DB_PASSWORD+x} ]; then
        DB_PASSWORD='';
    fi
    if [ -z ${DB_NAME+x} ]; then
        DB_NAME='';
    fi
    if [ -z ${DB_HOST+x} ]; then
        DB_HOST='';
    fi

    duplib::command_exists mysql && {
        mysql -h$DB_HOST -u$DB_USERNAME -p$DB_PASSWORD -D$DB_NAME;
    } || {
        duplib::error "Command mysql not found";
        exit 1;
    }
}

# Dump and gzip the databank defined in the configuration
function dupcli::mysql::dump() {
    duplib::command_exists mysqldump || {
        duplib::error "Command mysqldump not found";
        exit 1;
    }
    duplib::command_exists gzip || {
        duplib::error "Command gzip not found";
        exit 1;
    }

    local output_file="$HOME/$DB_NAME-$(date +%F-%H%m%S).sql.gz";
    if [ "$#" -eq 1 ]; then
        output_file="$1";
    fi

    if [ ! -e "$(dirname $output_file)" ]; then
        mkdir -p "$(dirname $output_file)";
    fi

    echo "Export database '$DB_NAME' to $output_file";
    mysqldump -h$DB_HOST -u$DB_USERNAME -p$DB_PASSWORD $DB_NAME|gzip -c > $output_file;
}
