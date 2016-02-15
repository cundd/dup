#!/bin/bash
set -o nounset
set -o errexit

: ${PHP_FPM_CONF_FILE_NAME="z-php-fpm.conf"}
: ${PHP_INI_FILE_NAME="z-dup.ini"}
: ${PHP_FEATURE_OPCACHE="true"}
: ${PHP_CUSTOM_INI=""}
: ${DUP_BASE="dup"}

DUP_LIB_PATH="${DUP_LIB_PATH:-$(dirname "$0")/../../../shell/lib/duplib.sh}";
source "$DUP_LIB_PATH";

function check_php() {
    if ! hash php 2>/dev/null; then
        duplib::fatal_error "Could not find PHP binary";
    fi
}

function detect_additional_php_ini_path() {
    php --ini|grep "Scan for additional .ini files in"|awk -F: '{ gsub(/ /, "", $2); print $2 }'
}

function detect_additional_php_fpm_ini_path() {
    if [[ -e "/etc/php5/fpm/conf.d" ]]; then
        echo "/etc/php5/fpm/conf.d";
    else
        echo "";
    fi
}

function detect_installation_uses_external_pool_files() {
    if [[ -e "/etc/php/fpm/pool.d" ]]; then
        echo "true";
    elif [[ -e "/etc/php5/fpm/pool.d" ]]; then
        echo "true";
    else
        echo "false";
    fi
}

function detect_php_fpm_conf_directory_path() {
    if [[ -e "/etc/php5/fpm/pool.d" ]]; then
        echo "/etc/php5/fpm/pool.d";
    else
        echo "/etc/php/php-fpm.d";
    fi
}

function detect_php_fpm_conf_file_path() {
    echo "$(detect_php_fpm_conf_directory_path)/$PHP_FPM_CONF_FILE_NAME";
}

function detect_loaded_php_ini_files() {
    php --ini|grep -A100 'Additional .ini files parsed:' | \
        sed 's/Additional .ini files parsed:\s*//' | \
        sed 's/,//';
}

function prepare_fpm_socket_folder() {
    local fpm_socket_folder="/run/php-fpm";

    if [[ ! -e $fpm_socket_folder ]]; then
        duplib::debug "Create FPM socket directory '$fpm_socket_folder'";
        mkdir -p "$fpm_socket_folder";
    fi
}

function configure_fpm() {
    prepare_fpm_socket_folder;
    local php_fpm_conf_file_directory=`detect_php_fpm_conf_directory_path`;
    local dupFilesPath="$DUP_BASE/files/php";

    if [[ ! -e "$php_fpm_conf_file_directory" ]]; then
        mkdir -p "$php_fpm_conf_file_directory";
    elif [[ ! -d "$php_fpm_conf_file_directory" ]]; then
        >&2 echo "Path $php_fpm_conf_file_directory exists but is no directory";
        return 1;
    fi

    ## Copy fpm file
    duplib::copy_os_specific_file "php" "$PHP_FPM_CONF_FILE_NAME" "$php_fpm_conf_file_directory/$PHP_FPM_CONF_FILE_NAME";
    chmod o+r "$php_fpm_conf_file_directory/$PHP_FPM_CONF_FILE_NAME";

    if [[ "$(detect_installation_uses_external_pool_files)" != "true" ]]; then
        duplib::add_string_to_file_if_not_found '^include=\/etc\/php\/php-fpm\.d\/\*\.conf' /etc/php/php-fpm.conf 'include=/etc/php/php-fpm.d/*.conf';
    fi

    add_environment_settings;
}

function configure_php_ini() {
    configure_php_ini_file 'default' `detect_additional_php_ini_path`;

    # If there is a separate folder for the FPM PHP INI file
    if [[ "$(detect_additional_php_fpm_ini_path)" != "" ]]; then
        configure_php_ini_file 'fpm' `detect_additional_php_fpm_ini_path`;
    fi
}

function configure_php_ini_file() {
    if [[ $# -lt 2 ]]; then
        duplib::error "No INI directory path given for $1";
        return;
    fi
    local additional_php_ini_path="$2";
    local dupFilesPath="$DUP_BASE/files/php";

    ## Copy PHP.ini file
    duplib::copy_os_specific_file "php" "$PHP_INI_FILE_NAME" "$additional_php_ini_path";
    chmod o+r "$additional_php_ini_path/$PHP_INI_FILE_NAME";

    if [[ "$PHP_FEATURE_OPCACHE" == "true" ]]; then
        configure_opcode_cache;
    fi

    for ini_row in $PHP_CUSTOM_INI; do
        echo $ini_row >> "$additional_php_ini_path/$PHP_INI_FILE_NAME";
    done
}

function set_typo3_context_env() {
    case "$TYPO3_SITE_ENV" in
        DEV)
            echo "env[TYPO3_CONTEXT] = 'Development'" >> $(detect_php_fpm_conf_file_path);
            ;;

        PROD)
            echo "env[TYPO3_CONTEXT] = 'Production'" >> $(detect_php_fpm_conf_file_path);
            ;;

        STAGE)
            echo "env[TYPO3_CONTEXT] = 'Testing'" >> $(detect_php_fpm_conf_file_path);
            ;;

        *)
            echo "env[TYPO3_CONTEXT] = '$TYPO3_SITE_ENV'" >> $(detect_php_fpm_conf_file_path);
            ;;
    esac
}

function add_environment_settings() {
    local php_fpm_conf_file_path=$(detect_php_fpm_conf_file_path);

    if [[ ! -z ${DB_USERNAME+x} ]] && [[ ! -z ${DB_NAME+x} ]] && [[ ! -z ${DB_PASSWORD+x} ]] && [[ ! -z ${DB_HOST+x} ]]; then
        echo "env[DB_USERNAME] = '$DB_USERNAME'"        >> $php_fpm_conf_file_path;
        echo "env[DB_NAME] = '$DB_NAME'"                >> $php_fpm_conf_file_path;
        echo "env[DB_PASSWORD] = '$DB_PASSWORD'"        >> $php_fpm_conf_file_path;
        echo "env[DB_HOST] = '$DB_HOST'"                >> $php_fpm_conf_file_path;
    fi

    # TODO: Move TYPO3 related setup
    if [[ ! -z ${TYPO3_SITE_ENV+x} ]]; then
        set_typo3_context_env;
        echo "env[SITE_ENV] = '$TYPO3_SITE_ENV'"        >> $php_fpm_conf_file_path;
    fi
}


function configure_opcode_cache() {
    local additional_php_ini_path=`detect_additional_php_ini_path`;
    local found="no";
    for file in $(detect_loaded_php_ini_files); do
        local result=$(grep '^zend_extension=opcache\.so' "$file" >/dev/null);
        if [[ $? -eq 0 ]]; then
            found="yes";
            break;
        fi
    done

    if [[ $found == "no" ]]; then
        echo "zend_extension=opcache.so" >> "$additional_php_ini_path/$PHP_INI_FILE_NAME";
    fi
}

function main() {
    check_php;
    configure_php_ini;
    configure_fpm;

    duplib::service_restart httpd;
    duplib::service_restart php-fpm;
}

main "$@";
