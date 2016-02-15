#!/bin/bash
set -o nounset
set -o errexit


: ${MYSQL_DATADIR="/var/lib/mysql"}
: ${DUP_CUSTOM_PROVISION_FOLDER="provision"}
: ${DB_NAME="vagrant"}
: ${DB_USERNAME="vagrant"}
: ${DB_PASSWORD="vagrant"}
: ${DB_HOST="localhost"}
: ${DB_ROOT_PASSWORD="vagrant"}
: ${DUP_BASE="dup"}

DUP_LIB_PATH="${DUP_LIB_PATH:-$(dirname "$0")/../../../shell/lib/duplib.sh}";
source "$DUP_LIB_PATH";

function prepare_installation() {
    if [[ -x "/etc/init.d/mariadb" ]]; then # Alpine
        /etc/init.d/mariadb setup;
    elif hash mysql_install_db 2>/dev/null; then # Arch Linux
        chown -R mysql:mysql $MYSQL_DATADIR;
        mysql_install_db --user=mysql --basedir=/usr/ --datadir=$MYSQL_DATADIR;
    fi
}

function test_root_password() {
    duplib::service_start_if_down mysqld &> /dev/null;
    {
        mysql -u root -p$DB_ROOT_PASSWORD -e "SHOW DATABASES" &> /dev/null;
    } || {
        echo "notset";
        return 0;
    }
    echo "set";
    return 0;
}

function provision_root() {
    mysqladmin -u root password $DB_ROOT_PASSWORD 2>/dev/null || mysqladmin -u root password -p$DB_ROOT_PASSWORD $DB_ROOT_PASSWORD
}

function test_client_database() {
    duplib::service_start_if_down mysqld &> /dev/null;
    set +e;
    local result="";
    result=$(mysql -u$DB_USERNAME -p$DB_PASSWORD -D$DB_NAME -e "SHOW TABLES;" 2>&1);
    local status=$?;
    if [[ $status -ne 0 ]]; then
        echo "notset";
    else
        echo "set";
    fi
    set -e;
}

function provision_client() {
    local Q1="CREATE DATABASE IF NOT EXISTS $1;"
    local Q2="GRANT USAGE ON *.* TO $2@localhost IDENTIFIED BY '$3';"
    local Q3="GRANT ALL PRIVILEGES ON $1.* TO $2@localhost;"
    local Q4="FLUSH PRIVILEGES;"
    local SQL="${Q1}${Q2}${Q3}${Q4}"

    mysql -uroot -p$DB_ROOT_PASSWORD -e "$SQL";
}

function provision_client_database() {
    local file="$1";
    local gz="$2";
    if [[ -e $file ]]; then # SQL file
        echo "Import datbase file $(basename $file)";
        echo "This may take a while...";

        if [[ "$gz" == "true" ]]; then
            gunzip < "$file" | mysql -u$DB_USERNAME -p$DB_PASSWORD -D$DB_NAME;
        else
            cat "$file" | mysql -u$DB_USERNAME -p$DB_PASSWORD -D$DB_NAME;
        fi
    fi
}

function provision_client_databases() {
    # Import databases from dup/files/database/import/
    local dupDatabaseFilesPath="$DUP_BASE/files/database/import";
    for file in $(ls -1 $dupDatabaseFilesPath/*.sql 2> /dev/null); do
        provision_client_database $file "false";
    done

    for file in $(ls -1 $dupDatabaseFilesPath/*.sql.gz 2> /dev/null); do
        provision_client_database $file "true";
    done

    # Import databases from provision/files/database/import/
    local dupCustomDatabaseFilesPath="/vagrant/$DUP_CUSTOM_PROVISION_FOLDER/files/database/import";
    for file in $(ls -1 $dupCustomDatabaseFilesPath/*.sql 2> /dev/null); do
        provision_client_database $file "false";
    done

    for file in $(ls -1 $dupCustomDatabaseFilesPath/*.sql.gz 2> /dev/null); do
        provision_client_database $file "true";
    done
}

function test_client_database_tables() {
    if [[ $(mysql -u$DB_USERNAME -p$DB_PASSWORD -D$DB_NAME -e "SHOW TABLES") == "" ]]; then
        echo "notset";
    else
        echo "set";
    fi
}

function provision_base() {
    if [[ `test_root_password` == "notset" ]]; then
        echo "Provision MySQL base";
        duplib::service_stop_if_running mysqld;
        prepare_installation;
        duplib::service_start mysqld;

        provision_root;
        #mysql_secure_installation
    else
        echo "MySQL base already provisioned";
    fi
}

function provision_user() {
    if [[ `test_client_database` == "notset" ]]; then
        echo "Provision MySQL client";
        provision_client $DB_NAME $DB_USERNAME $DB_PASSWORD;
    else
        echo "MySQL client already provisioned";
    fi

    if [[ `test_client_database_tables` == "notset" ]]; then
        echo "Provision MySQL client tables";
        provision_client_databases;
    else
        echo "MySQL client table already exists";
    fi
}

function main() {
    provision_base;
    provision_user;
}

main "$@";
