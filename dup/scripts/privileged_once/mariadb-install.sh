#!/bin/bash
set -o nounset
set -o errexit


MYSQL_DATADIR="${MYSQL_DATADIR:-/var/lib/mysql}";

DUP_BASE="${DUP_BASE:-dup}";
DUP_LIB_PATH="${DUP_LIB_PATH:-$(dirname "$0")/../special/lib.sh}";
source "$DUP_LIB_PATH";

function prepare-installation() {
    if [[ -x "/etc/init.d/mariadb" ]]; then # Alpine
        /etc/init.d/mariadb setup;
    elif hash mysql_install_db 2>/dev/null; then # Arch Linux
        chown -R mysql:mysql $MYSQL_DATADIR;
        mysql_install_db --user=mysql --basedir=/usr/ --datadir=$MYSQL_DATADIR;
    fi
}

function test-root-password() {
    {
        mysql -u root -p$DB_ROOT_PASSWORD -e "SHOW DATABASES" &> /dev/null;
    } || {
        echo "notset";
        return 0;
    }
    echo "set";
    return 0;
}

function provision-root() {
    mysqladmin -u root password $DB_ROOT_PASSWORD 2>/dev/null || mysqladmin -u root password -p$DB_ROOT_PASSWORD $DB_ROOT_PASSWORD
}

function test-client-database() {
    set +e;
    local result="";
    result=$(mysql -u$DB_USERNAME -p$DB_PASSWORD -D$DB_NAME 2>&1);
    local status=$?;
    if [[ $status -ne 0 ]]; then
        echo "notset";
    else
        echo "set";
    fi
    set -e;
}

function provision-client() {
    local Q1="CREATE DATABASE IF NOT EXISTS $1;"
    local Q2="GRANT USAGE ON *.* TO $2@localhost IDENTIFIED BY '$3';"
    local Q3="GRANT ALL PRIVILEGES ON $1.* TO $2@localhost;"
    local Q4="FLUSH PRIVILEGES;"
    local SQL="${Q1}${Q2}${Q3}${Q4}"

    mysql -uroot -p$DB_ROOT_PASSWORD -e "$SQL";
}

function provision-client-database() {
    local dupDatabaseFilesPath="/vagrant/$DUP_BASE/files/database";
    local dupImportDatabaseName="import.sql";
    if [[ -e "$dupDatabaseFilesPath/$dupImportDatabaseName" ]]; then # SQL file
        echo "Import $dupImportDatabaseName";
        cat "$dupDatabaseFilesPath/$dupImportDatabaseName" | mysql -u$DB_USERNAME -p$DB_PASSWORD -D$DB_NAME;
    elif [[ -e "$dupDatabaseFilesPath/$dupImportDatabaseName.gz" ]]; then # GZIP SQL file
        echo "Import $dupImportDatabaseName.gz";
        gunzip < "$dupDatabaseFilesPath/$dupImportDatabaseName.gz" | mysql -u$DB_USERNAME -p$DB_PASSWORD -D$DB_NAME;
    else
        echo "No database file to import";
    fi
}

function test-client-database-tables() {
    if [[ $(mysql -u$DB_USERNAME -p$DB_PASSWORD -D$DB_NAME -e "SHOW TABLES") == "" ]]; then
        echo "notset";
    else
        echo "set";
    fi
}

function provision-base() {
    if [[ `test-root-password` == "notset" ]]; then
        echo "Provision MySQL base";
        duplib::service_stop mysqld;
        prepare-installation;
        duplib::service_start mysqld;

        provision-root;
        #mysql_secure_installation
    else
        echo "MySQL base already provisioned";
    fi
}

function provision-user() {
    if [[ `test-client-database` == "notset" ]]; then
        echo "Provision MySQL client";
        provision-client $DB_NAME $DB_USERNAME $DB_PASSWORD;
    else
        echo "MySQL client already provisioned";
    fi


    if [[ `test-client-database-tables` == "notset" ]]; then
       echo "Provision MySQL client tables";
       provision-client-database;
    fi
}

function run() {
    provision-base;
    provision-user;

}


run $@
