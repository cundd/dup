#!/bin/bash
set -o nounset
set -o errexit


MYSQL_DATADIR="${MYSQL_DATADIR:-/var/lib/mysql}";

DUP_LIB_PATH="${DUP_LIB_PATH:-$(dirname "$0")/../special/lib.sh}";
source "$DUP_LIB_PATH";

function prepareMySQLInstallation () {
    if [[ -x "/etc/init.d/mariadb" ]]; then # Alpine
        /etc/init.d/mariadb setup;
    elif hash mysql_install_db 2>/dev/null; then # Arch Linux
        chown mysql:mysql $MYSQL_DATADIR -R;
        mysql_install_db --user=mysql --datadir=$MYSQL_DATADIR;
    fi

}

function testMYSQLRootPassword () {
    {
        mysql -u root -p$DB_ROOT_PASSWORD -e "SHOW DATABASES" &> /dev/null;
    } || {
        echo "notset";
        return 0;
    }
    echo "set";
    return 0;
}

function provisionRoot () {
    mysqladmin -u root password $DB_ROOT_PASSWORD 2>/dev/null || mysqladmin -u root password -p$DB_ROOT_PASSWORD $DB_ROOT_PASSWORD
}

function provisionDatabase () {
    local Q1="CREATE DATABASE IF NOT EXISTS $1;"
    local Q2="GRANT USAGE ON *.* TO $2@localhost IDENTIFIED BY '$3';"
    local Q3="GRANT ALL PRIVILEGES ON $1.* TO $2@localhost;"
    local Q4="FLUSH PRIVILEGES;"
    local SQL="${Q1}${Q2}${Q3}${Q4}"

    mysql -uroot -p$DB_ROOT_PASSWORD -e "$SQL";
}

function provision () {
    stop-service mysqld;
    prepareMySQLInstallation;
    start-service mysqld;

    provisionRoot;
    provisionDatabase $DB_NAME $DB_USERNAME $DB_PASSWORD;
    #mysql_secure_installation
}

function run () {
    if [[ `testMYSQLRootPassword` == "notset" ]]; then
        echo "Provision MySQL";
        provision;
    else
        echo "MySQL already provisioned";
    fi
}


run $@
