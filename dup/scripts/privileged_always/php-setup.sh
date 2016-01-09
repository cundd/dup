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

function detect-additional-php-ini-path() {
    php --ini|grep "Scan for additional .ini files in"|awk -F: '{ gsub(/ /, "", $2); print $2 }'
}

function detect-loaded-php-ini-files() {
    php --ini|grep -A100 'Additional .ini files parsed:' | \
        sed 's/Additional .ini files parsed:\s*//' | \
        sed 's/,//';
}

function prepare-fpm-socket-folder() {
    local fpmSocketFolder="/run/php-fpm";

    if [[ ! -e $fpmSocketFolder ]]; then
        echo "create $fpmSocketFolder"
        mkdir -p "$fpmSocketFolder";
    fi
}

function configure-fpm() {
    prepare-fpm-socket-folder;
    local dupFilesPath="/vagrant/$DUP_BASE/files/php";

    if [[ ! -e "$PHP_FPM_CONF_FILE_DIRECTORY" ]]; then
        mkdir -p "$PHP_FPM_CONF_FILE_DIRECTORY";
    elif [[ ! -d "$PHP_FPM_CONF_FILE_DIRECTORY" ]]; then
        >&2 echo "Path $PHP_FPM_CONF_FILE_DIRECTORY exists but is no directory";
        return 1;
    fi

    ## Copy fpm file
    duplib::copy_linux_distribution_specific_file "php" "$PHP_INI_FILE_NAME" "$PHP_FPM_CONF_FILE_PATH";
    chmod o+r "$PHP_FPM_CONF_FILE_PATH";

    duplib::add_string_to_file_if_not_found '^include=\/etc\/php\/php-fpm\.d\/\*\.conf' /etc/php/php-fpm.conf 'include=/etc/php/php-fpm.d/*.conf';

    add_environment_settings;
}

function configure-opcode-cache() {
    local found="no";
    for file in $(detect-loaded-php-ini-files); do
        local result=$(grep '^zend_extension=opcache\.so' "$file" >/dev/null);
        if [[ $? -eq 0 ]]; then
            found="yes";
            break;
        fi
    done

    if [[ $found == "no" ]]; then
        echo "zend_extension=opcache.so" >> "$additionalPHPIniPath/$PHP_INI_FILE_NAME";
    fi
}

function configure_php_ini() {
    local additionalPHPIniPath=`detect-additional-php-ini-path`;
    local dupFilesPath="/vagrant/$DUP_BASE/files/php";

    ## Copy PHP.ini file
    duplib::copy_linux_distribution_specific_file "php" "$PHP_INI_FILE_NAME" "$additionalPHPIniPath";
    chmod o+r "$additionalPHPIniPath/$PHP_INI_FILE_NAME";

    if [[ "$PHP_FEATURE_OPCACHE" == "true" ]]; then
        configure-opcode-cache;
    fi

    for iniRow in $PHP_CUSTOM_INI; do
        echo $iniRow >> "$additionalPHPIniPath/$PHP_INI_FILE_NAME";
    done
}

function set_typo3_context_env() {
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

function add_environment_settings() {
    set_typo3_context_env;
    echo "env[SITE_ENV] = '$TYPO3_SITE_ENV'"        >> $PHP_FPM_CONF_FILE_PATH;
    echo "env[DB_USERNAME] = '$DB_USERNAME'"        >> $PHP_FPM_CONF_FILE_PATH;
    echo "env[DB_NAME] = '$DB_NAME'"                >> $PHP_FPM_CONF_FILE_PATH;
    echo "env[DB_PASSWORD] = '$DB_PASSWORD'"        >> $PHP_FPM_CONF_FILE_PATH;
    echo "env[DB_HOST] = '$DB_HOST'"                >> $PHP_FPM_CONF_FILE_PATH;
}

function main() {
    configure_php_ini;
    configure-fpm;

    duplib::service_restart httpd;
    duplib::service_restart php-fpm;
}

main $@
