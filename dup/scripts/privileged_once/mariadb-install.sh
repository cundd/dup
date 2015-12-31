#!/bin/bash
set -o nounset
set -o errexit


MYSQL_DATADIR="${MYSQL_DATADIR:-/var/lib/mysql}";

function prepareMySQLInstallation () {
    chown mysql:mysql $MYSQL_DATADIR -R;
    mysql_install_db --user=mysql --basedir=/usr --datadir=$MYSQL_DATADIR;
}

function testMYSQLRootPassword () {
    {
        mysql -u root -p$MYSQL_ROOT_PASSWORD -e "SHOW DATABASES" &> /dev/null;
    } || {
        echo "notset";
        return 0;
    }
    echo "set";
    return 0;
}

function provisionRoot () {
    mysqladmin -u root password $MYSQL_ROOT_PASSWORD 2>/dev/null || mysqladmin -u root password -p$MYSQL_ROOT_PASSWORD $MYSQL_ROOT_PASSWORD
}

function provisionDatabase () {
    local Q1="CREATE DATABASE IF NOT EXISTS $1;"
    local Q2="GRANT USAGE ON *.* TO $2@localhost IDENTIFIED BY '$3';"
    local Q3="GRANT ALL PRIVILEGES ON $1.* TO $2@localhost;"
    local Q4="FLUSH PRIVILEGES;"
    local SQL="${Q1}${Q2}${Q3}${Q4}"

    mysql -uroot -p$MYSQL_ROOT_PASSWORD -e "$SQL";
}

function provision () {
    systemctl stop mysqld.service;
    prepareMySQLInstallation;
    systemctl start mysqld.service;

    provisionRoot;
    provisionDatabase $MYSQL_DATABASE $MYSQL_USER $MYSQL_PASSWORD;
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
