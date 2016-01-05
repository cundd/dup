#!/bin/bash
set -o nounset
set -o errexit

PHP_FPM_CONF_FILE_NAME=${PHP_FPM_CONF_FILE_NAME:-"z-php-fpm.conf"};
PHP_FPM_CONF_FILE_DIRECTORY=${PHP_FPM_CONF_FILE_DIRECTORY:-"/etc/php/php-fpm.d"};
PHP_FPM_CONF_FILE_PATH=${PHP_FPM_CONF_FILE_PATH:-"$PHP_FPM_CONF_FILE_DIRECTORY/$PHP_FPM_CONF_FILE_NAME"};

PHP_INI_FILE_NAME=${PHP_INI_FILE_NAME:-"z-dup.ini"};
PHP_FEATURE_OPCACHE="${PHP_FEATURE_OPCACHE:-true}";
PHP_CUSTOM_INI=${PHP_CUSTOM_INI:-""};
DUP_BASE="${DUP_BASE:-dup}";

DUP_LIB_PATH="${DUP_LIB_PATH:-$(dirname "$0")/../special/lib.sh}";
source "$DUP_LIB_PATH";

function detectAdditionalPHPIniPath() {
    php --ini|grep "Scan for additional .ini files in"|awk -F: '{ gsub(/ /, "", $2); print $2 }'
}

function configureApache() {
    local fileToCopy="httpd-php-fpm.conf";
    local apacheBasePath="";
    local apacheExtraConfigurationPath="";
    local checkIncludeString="no";

    if [[ -e "/etc/apache2/" ]]; then
        apacheBasePath="/etc/apache2";
        apacheExtraConfigurationPath="$apacheBasePath/conf.d";
    elif [[ -e "/etc/httpd/conf/" ]]; then
        apacheBasePath="/etc/httpd/conf";
        apacheExtraConfigurationPath="$apacheBasePath/extra";
        checkIncludeString="yes";
    else
        >&2 echo "Apache configuration directory not found";
        return 1;
    fi

    cp "/vagrant/$DUP_BASE/files/php/$fileToCopy" "$apacheExtraConfigurationPath";
    chmod o+r "$apacheExtraConfigurationPath/$fileToCopy";

    if [[ $checkIncludeString == "yes" ]]; then
        add-string-to-file-if-not-found "Include conf/extra/$fileToCopy" "$apacheBasePath/httpd.conf";
    fi
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
    if [[ ! -e "$PHP_FPM_CONF_FILE_DIRECTORY" ]]; then
        mkdir -p "$PHP_FPM_CONF_FILE_DIRECTORY";
    elif [[ ! -d "$PHP_FPM_CONF_FILE_DIRECTORY" ]]; then
        >&2 echo "Path $PHP_FPM_CONF_FILE_DIRECTORY exists but is no directory";
        return 1;
    fi
    cp "/vagrant/$DUP_BASE/files/php/$PHP_FPM_CONF_FILE_NAME" "$PHP_FPM_CONF_FILE_PATH";
    chmod o+r "$PHP_FPM_CONF_FILE_PATH";

    add-string-to-file-if-not-found '^include=\/etc\/php\/php-fpm\.d\/\*\.conf' /etc/php/php-fpm.conf 'include=/etc/php/php-fpm.d/*.conf';

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

    restart-service httpd;
    restart-service php-fpm;
}

run $@
