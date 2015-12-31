#!/bin/bash
set -o nounset
set -o errexit

PHP_FPM_CONF_FILE_NAME=${PHP_FPM_CONF_FILE_NAME:-"php-fpm.conf"};
PHP_FPM_CONF_FILE_PATH=${PHP_FPM_CONF_FILE_PATH:-"/etc/php/fpm.d/$PHP_FPM_CONF_FILE_NAME"};

PHP_INI_FILE_NAME=${PHP_INI_FILE_NAME:-"z-dup.ini"};

function detectAdditionalPHPIniPath() {
    php --ini|grep "Scan for additional .ini files in"|awk -F: '{ gsub(/ /, "", $2); print $2 }'
}

function addStringToFileIfNotFound () {
    if [[ -z ${1+x} ]]; then echo "Missing argument 1 (pattern)"; return 1; fi;
    if [[ -z ${2+x} ]]; then echo "Missing argument 2 (file)"; return 1; fi;

    local pattern=$1;
    local file=$2;

    if [[ -z ${3+x} ]]; then
        local string=$pattern;
    else
        local string=$3;
    fi;

    grep -q "$pattern" "$file" || echo "$string" >> "$file";
}

function configureApache() {
    local FILE_TO_COPY="httpd-php-fpm.conf"

    cp "/vagrant/$DUP_BASE/files/php/$FILE_TO_COPY" /etc/httpd/conf/extra;
    chmod o+r "/etc/httpd/conf/extra/$FILE_TO_COPY";

    addStringToFileIfNotFound "Include conf/extra/$FILE_TO_COPY" /etc/httpd/conf/httpd.conf;
}

function addEnvironmentSettings() {
    echo "env[SITE_ENV] = '$TYPO3_SITE_ENV'" >> $PHP_FPM_CONF_FILE_PATH;
    echo "env[DB_USERNAME] = '$MYSQL_USER'" >> $PHP_FPM_CONF_FILE_PATH;
    echo "env[DB_NAME] = '$MYSQL_DATABASE'" >> $PHP_FPM_CONF_FILE_PATH;
    echo "env[DB_PASSWORD] = '$MYSQL_PASSWORD'" >> $PHP_FPM_CONF_FILE_PATH;
    echo "env[DB_HOST] = 'localhost'" >> $PHP_FPM_CONF_FILE_PATH;

}

function configureFPM() {
    echo $PHP_FPM_CONF_FILE_PATH;
    cp "/vagrant/$DUP_BASE/files/php/$PHP_FPM_CONF_FILE_NAME" "$PHP_FPM_CONF_FILE_PATH";
    chmod o+r "$PHP_FPM_CONF_FILE_PATH";

    addStringToFileIfNotFound '^include=\/etc\/php\/fpm\.d\/\*\.conf' /etc/php/php-fpm.conf 'include=/etc/php/fpm.d/*.conf';

    addEnvironmentSettings;
}

function configurePHPIni() {
    cp "/vagrant/$DUP_BASE/files/php/$PHP_INI_FILE_NAME" `detectAdditionalPHPIniPath`;
    chmod o+r $(detectAdditionalPHPIniPath)"/$PHP_INI_FILE_NAME";
}


function run() {
    configureApache;
    configurePHPIni;
    configureFPM;
    systemctl restart httpd.service
    systemctl restart php-fpm.service
}

run $@
