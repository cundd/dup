#!/bin/bash
set -o nounset
set -o errexit

DUP_LIB_PATH="${DUP_LIB_PATH:-$(dirname "$0")/../special/lib.sh}";
source "$DUP_LIB_PATH";

function prepare-file-system() {
    local runDirectory=$(grep "# Mutex default:" $(detect-apache-configuration-file)|awk -F: '{ print $2 }');
    if [[ ! -e $runDirectory ]]; then
        mkdir $runDirectory;
    fi
}

function prepare-apache-proxy() {
    add-string-to-file-if-not-found '^LoadModule slotmem_shm_module modules\/mod_slotmem_shm\.so' $(detect-apache-configuration-file) 'LoadModule slotmem_shm_module modules/mod_slotmem_shm.so';
}

function prepare-document-root() {
    #detect-and-set-document-root;
    local documentRoot=$(get-vhost-document-root);

    # Try
    set +e
    if [[ "$(getent group apache)" != "" ]]; then
        chown apache:apache $documentRoot;
        chmod g+w $documentRoot;
    elif [[ "$(getent group http)" != "" ]]; then
        chown http:http $documentRoot;
        chmod g+w $documentRoot;
    else
        >&2 echo "Could not detect apache/http group name";
    fi
    set -e
}

function prepare-vagrant-user() {
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
            >&2 echo "No command known to add the user to the group";
        fi
    else
        echo "User $userName already in apache group: $apacheGroup";
    fi
}

function configure-vhost() {
    local fileToCopy="vhost.conf";
    local apacheExtraConfigurationPath="";
    local checkIncludeString="no";

    if [[ -e "/etc/apache2/" ]]; then
        apacheExtraConfigurationPath="/etc/apache2/conf.d";
    elif [[ -e "/etc/httpd/conf/" ]]; then
        apacheExtraConfigurationPath="/etc/httpd/conf/extra";
        checkIncludeString="yes";
    else
        >&2 echo "Apache configuration directory not found";
        return 1;
    fi

    ## Copy vhost file
    copy-linux-distribution-specific-file "apache" "$fileToCopy" "$apacheExtraConfigurationPath";
    chmod o+r "$apacheExtraConfigurationPath/$fileToCopy";

    # Check if the vhost file will be loaded
    if [[ $checkIncludeString == "yes" ]]; then
        add-string-to-file-if-not-found "Include conf/extra/$fileToCopy" $(detect-apache-configuration-file);
    fi
}

function run() {
    prepare-file-system;
    prepare-apache-proxy;
    prepare-document-root;
    prepare-vagrant-user;
    configure-vhost;
}

run $@
