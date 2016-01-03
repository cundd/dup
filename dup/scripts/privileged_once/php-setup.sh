#!/bin/bash
set -o nounset
set -o errexit

PHP_FPM_CONF_FILE_NAME=${PHP_FPM_CONF_FILE_NAME:-"z-php-fpm.conf"};
PHP_FPM_CONF_FILE_PATH=${PHP_FPM_CONF_FILE_PATH:-"/etc/php/php-fpm.d/$PHP_FPM_CONF_FILE_NAME"};

PHP_INI_FILE_NAME=${PHP_INI_FILE_NAME:-"z-dup.ini"};
PHP_FEATURE_OPCACHE="${PHP_FEATURE_OPCACHE:-true}";
PHP_CUSTOM_INI=${PHP_CUSTOM_INI:-""};
DUP_BASE="${DUP_BASE:-dup}";

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
    local fileToCopy="httpd-php-fpm.conf"

    cp "/vagrant/$DUP_BASE/files/php/$fileToCopy" /etc/httpd/conf/extra;
    chmod o+r "/etc/httpd/conf/extra/$fileToCopy";

    addStringToFileIfNotFound "Include conf/extra/$fileToCopy" /etc/httpd/conf/httpd.conf;
}

function setTYPO3ContextEnv() {
    case "$TYPO3_SITE_ENV" in
        DEV)
            echo "env[TYPO3_CONTEXT] = 'Development'" >> $PHP_FPM_CONF_FILE_PATH;
            ;;

        PROD)
            echo "env[TYPO3_CONTEXT] = 'Production'" >> $PHP_FPM_CONF_FILE_PATH;
            ;;

        STAGE)
            echo "env[TYPO3_CONTEXT] = 'Testing'" >> $PHP_FPM_CONF_FILE_PATH;
            ;;

        *)
            echo "env[TYPO3_CONTEXT] = '$TYPO3_SITE_ENV'" >> $PHP_FPM_CONF_FILE_PATH;
            ;;
    esac
}

function addEnvironmentSettings() {
    setTYPO3ContextEnv;
    echo "env[SITE_ENV] = '$TYPO3_SITE_ENV'"        >> $PHP_FPM_CONF_FILE_PATH;
    echo "env[DB_USERNAME] = '$DB_USERNAME'"        >> $PHP_FPM_CONF_FILE_PATH;
    echo "env[DB_NAME] = '$DB_NAME'"                >> $PHP_FPM_CONF_FILE_PATH;
    echo "env[DB_PASSWORD] = '$DB_PASSWORD'"        >> $PHP_FPM_CONF_FILE_PATH;
    echo "env[DB_HOST] = '$DB_HOST'"                >> $PHP_FPM_CONF_FILE_PATH;
}

function configureFPM() {
    cp "/vagrant/$DUP_BASE/files/php/$PHP_FPM_CONF_FILE_NAME" "$PHP_FPM_CONF_FILE_PATH";
    chmod o+r "$PHP_FPM_CONF_FILE_PATH";

    addStringToFileIfNotFound '^include=\/etc\/php\/php-fpm\.d\/\*\.conf' /etc/php/php-fpm.conf 'include=/etc/php/php-fpm.d/*.conf';

    addEnvironmentSettings;
}

function configurePHPIni() {
    local additionalPHPIniPath=`detectAdditionalPHPIniPath`;
    cp "/vagrant/$DUP_BASE/files/php/$PHP_INI_FILE_NAME" $additionalPHPIniPath;
    chmod o+r "$additionalPHPIniPath/$PHP_INI_FILE_NAME";

    if [[ "$PHP_FEATURE_OPCACHE" == "true" ]]; then
        echo "zend_extension=opcache.so" >> "$additionalPHPIniPath/$PHP_INI_FILE_NAME";
    fi

    for iniRow in $PHP_CUSTOM_INI; do
        echo $iniRow >> "$additionalPHPIniPath/$PHP_INI_FILE_NAME";
    done
}

function run() {
    configureApache;
    configurePHPIni;
    configureFPM;
    systemctl restart httpd.service
    systemctl restart php-fpm.service
}

run $@
