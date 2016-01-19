#!/bin/bash
set -o nounset
set -o errexit

DUP_LIB_PATH="${DUP_LIB_PATH:-$(dirname "$0")/../special/lib.sh}";
source "$DUP_LIB_PATH";

function prepare_file_system() {
    local apacheConfFile=$(duplib::detect_apache_configuration_file);
    local runDirectory=$(grep "# Mutex default:" $apacheConfFile|awk -F: '{ print $2 }');

    if [[ "$runDirectory" != "" ]]; then
        if [[ ! -e $runDirectory ]]; then
            mkdir $runDirectory;
        fi
    fi
}

function prepare_apache_proxy() {
    duplib::add_string_to_file_if_not_found '^LoadModule slotmem_shm_module modules\/mod_slotmem_shm\.so' $(duplib::detect_apache_configuration_file) 'LoadModule slotmem_shm_module modules/mod_slotmem_shm.so';
}

function prepare_apache_rewrite() {
    duplib::add_string_to_file_if_not_found '^LoadModule rewrite_module modules\/mod_rewrite\.so' $(duplib::detect_apache_configuration_file) 'LoadModule rewrite_module modules/mod_rewrite.so';
}

function prepare_document_root() {
    #duplib::detect_and_set_document_root;
    local documentRoot=$(duplib::get_vhost_document_root);

    # Try
    set +e
    if [[ "$(getent group apache)" != "" ]]; then
        chown apache:apache $documentRoot;
        chmod g+w $documentRoot;
    elif [[ "$(getent group http)" != "" ]]; then
        chown http:http $documentRoot;
        chmod g+w $documentRoot;
    else
        duplib::error "Could not detect apache/http group name";
    fi
    set -e
}

function prepare_vagrant_user() {
    local userName="vagrant";
    local apacheGroup="";
    if [[ "$(getent group apache)" != "" ]]; then
        apacheGroup="apache";
    elif [[ "$(getent group http)" != "" ]]; then
        apacheGroup="http";
    fi

    if [[ $apacheGroup != "" ]] && [[ $(id $userName|grep "($apacheGroup)") == "" ]]; then
        echo "Add user $userName to apache group: $apacheGroup";
        if hash usermod 2>/dev/null; then # usermod
            usermod -a -G $apacheGroup $userName;
        elif hash adduser 2>/dev/null; then # adduser
            adduser $userName $apacheGroup;
        else
            duplib::error "No command known to add the user to the group";
        fi
    else
        echo "User $userName already in apache group: $apacheGroup";
    fi
}

function configure_vhost() {
    local fileToCopy="vhost.conf";
    local apacheExtraConfigurationPath="";
    local checkIncludeString="no";

    if [[ -e "/etc/apache2/" ]]; then
        apacheExtraConfigurationPath="/etc/apache2/conf.d";
    elif [[ -e "/etc/httpd/conf/" ]]; then
        apacheExtraConfigurationPath="/etc/httpd/conf/extra";
        checkIncludeString="yes";
    else
        duplib::error "Apache configuration directory not found";
        return 1;
    fi

    ## Copy vhost file
    duplib::copy_linux_distribution_specific_file "apache" "$fileToCopy" "$apacheExtraConfigurationPath";
    chmod o+r "$apacheExtraConfigurationPath/$fileToCopy";

    # Check if the vhost file will be loaded
    if [[ $checkIncludeString == "yes" ]]; then
        duplib::add_string_to_file_if_not_found "Include conf/extra/$fileToCopy" $(duplib::detect_apache_configuration_file);
    fi
}

function main() {
    prepare_file_system;
    prepare_apache_rewrite;
    prepare_apache_proxy;
    prepare_document_root;
    prepare_vagrant_user;
    configure_vhost;

    duplib::service_restart httpd;
}

main $@
