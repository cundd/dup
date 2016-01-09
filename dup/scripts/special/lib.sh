# --------------------------------------------------------
# Helpers
# --------------------------------------------------------
function error() {
    >& 2 echo "$@";
}

# --------------------------------------------------------
# HTTP/Apache methods
# --------------------------------------------------------
function _document_root() {
    echo "/var/www/vhosts/dup.cundd.net/httpdocs";
}

function detect_and_set_document_root() {
    local apacheBasePath="/etc";

    if [[ -e "/etc/apache2/" ]]; then
        apacheBasePath="/etc/apache2";
    elif [[ -e "/etc/httpd/conf/" ]]; then
        apacheBasePath="/etc/httpd/conf";
    fi

    local apacheConfFile=$(grep -lir '^DocumentRoot' $apacheBasePath|head -n1);

    add_string_to_file_if_not_found "DocumentRoot \"$(_document_root)\"" $apacheConfFile;
    detect_document_root;
}

function detect_document_root() {
    # local apacheBasePath="/etc";
    #
    # if [[ -e "/etc/apache2/" ]]; then
    #     apacheBasePath="/etc/apache2";
    # elif [[ -e "/etc/httpd/conf/" ]]; then
    #     apacheBasePath="/etc/httpd/conf";
    # fi
    #echo $(grep -hir '^DocumentRoot' $apacheBasePath|head -n1|awk '/^DocumentRoot/{gsub("\"", ""); print $2}')
    _document_root;
}

function get_vhost_document_root() {
    echo "/var/www/vhosts/dup.cundd.net/httpdocs";
}

function detect_apache_configuration_file() {
    if [[ -e "/etc/apache2/httpd.conf" ]]; then
        echo "/etc/apache2/httpd.conf";
    elif [[ -e "/etc/httpd/conf/httpd.conf" ]]; then
        echo "/etc/httpd/conf/httpd.conf";
    else
        find /etc -name "httpd.conf"|head -n1;
    fi
}

# --------------------------------------------------------
# OS/Linux methods
# --------------------------------------------------------
function detect_linux_distribution() {
    if   [ -f "/etc/SUSE-release" ];          then echo "Novell SUSE";
    elif [ -f "/etc/redhat-release," ];       then echo "Red Hat";
    elif [ -f "/etc/fedora-release" ];        then echo "Fedora";
    elif [ -f "/etc/slackware-release," ];    then echo "Slackware";
    elif [ -f "/etc/debian_release," ];       then echo "Debian";
    elif [ -f "/etc/mandrake-release" ];      then echo "Mandrake";
    elif [ -f "/etc/yellowdog-release" ];     then echo "Yellow dog";
    elif [ -f "/etc/sun-release" ];           then echo "Sun JDS";
    elif [ -f "/etc/release" ];               then echo "Solaris/Sparc";
    elif [ -f "/etc/gentoo-release" ];        then echo "Gentoo";
    elif [ -f "/etc/UnitedLinux-release" ];   then echo "UnitedLinux";
    elif [ -f "/etc/lsb-release" ];           then echo "ubuntu";
    elif [ -f "/etc/alpine-release" ];        then echo "Alpine";
    elif [ -f "/etc/arch-release" ];          then echo "Arch Linux";
    else echo "Linux"; fi
}

function get_linux_distribution_release_file() {
    if   [ -f "/etc/SUSE-release" ];          then echo "/etc/SUSE-release";
    elif [ -f "/etc/redhat-release" ];        then echo "/etc/redhat-release";
    elif [ -f "/etc/fedora-release" ];        then echo "/etc/fedora-release";
    elif [ -f "/etc/slackware-release" ];     then echo "/etc/slackware-release";
    elif [ -f "/etc/debian_release" ];        then echo "/etc/debian_release";
    elif [ -f "/etc/mandrake-release" ];      then echo "/etc/mandrake-release";
    elif [ -f "/etc/yellowdog-release" ];     then echo "/etc/yellowdog-release";
    elif [ -f "/etc/sun-release" ];           then echo "/etc/sun-release";
    elif [ -f "/etc/release" ];               then echo "/etc/release" ];
    elif [ -f "/etc/gentoo-release" ];        then echo "/etc/gentoo-release";
    elif [ -f "/etc/UnitedLinux-release" ];   then echo "/etc/UnitedLinux-release";
    elif [ -f "/etc/lsb-release" ];           then echo "/etc/lsb-release";
    elif [ -f "/etc/alpine-release" ];        then echo "/etc/alpine-release";
    elif [ -f "/etc/arch-release" ];          then echo "/etc/arch-release";
    else
        error "Could not determine the release file";
        return 1;
    fi
}

function get_dup_linux_distribution_specific_folder() {
    basename `get_linux_distribution_release_file` | sed 's/release//' | sed 's/[-_]//'| tr '[:upper:]' '[:lower:]';
}

function copy_linux_distribution_specific_file() {
    if [ -z ${1+x} ]; then
        error "Missing argument directory";
        return 1;
    else
        local subDirectory="$1";
    fi
    if [ -z ${2+x} ]; then
        error "Missing argument fileName";
        return 1;
    else
        local fileName="$2";
    fi
    if [ -z ${3+x} ]; then
        error "Missing argument destination";
        return 1;
    else
        local destination="$3";
    fi

    local dupFilesPath="/vagrant/$DUP_BASE/files/$subDirectory";

    ## Check if there is a special file for the linux distribution
    if [[ -e "$dupFilesPath/$(get_dup_linux_distribution_specific_folder)/$fileName" ]]; then
        cp "$dupFilesPath/$(get_dup_linux_distribution_specific_folder)/$fileName" "$destination";
    elif [[ -e "$dupFilesPath/general/$fileName" ]]; then # Copy the default file
        cp "$dupFilesPath/general/$fileName" "$destination";
    else
        error "No distribution specific or general file $fileName found $(get_dup_linux_distribution_specific_folder)";
        return 1;
    fi
}

# --------------------------------------------------------
# File methods
# --------------------------------------------------------
function add_string_to_file_if_not_found() {
    if [[ -z ${1+x} ]]; then echo "Missing argument 1 (pattern)"; return 1; fi;
    if [[ -z ${2+x} ]]; then echo "Missing argument 2 (file)"; return 1; fi;

    local pattern=$1;
    local file=$2;

    if [[ -z ${3+x} ]]; then
        local string=$pattern;
    else
        local string=$3;
    fi

    grep -q "$pattern" "$file" || echo "$string" >> "$file";
}

# --------------------------------------------------------
# Service methods
# --------------------------------------------------------
function _get_service_alternative() {
    if [[ "$1" == "mysqld" ]]; then
        echo "mariadb";
    fi
    echo "";
}

function _get_service_real() {
    if [[ "$(_get_service_alternative $1)" != "" ]]; then
        echo $(_get_service_alternative $1);
    else
        echo "$1";
    fi
}

# Starting
function _service_start_systemd() {
    systemctl daemon-reload;
    systemctl start "$1.service";
}

function _service_start_rc-service() {
    rc-service "$1" start;
}

function _service_start_initd() {
    "/etc/init.d/$1" start;
}

function service_start() {
    if [ -z ${1+x} ]; then
        error "Missing argument service";
        return 1;
    fi

    if hash systemctl 2>/dev/null; then # systemd
        _service_start_systemd $@;

    elif hash rc-service 2>/dev/null; then # rc-service
        _get_service_real $1
        _service_start_rc-service $(_get_service_real $1);

    elif [[ -x "/etc/init.d/$1" ]]; then # init.d
        _service_start_initd $@;

    elif [[ "$(_get_service_alternative $1)" != "" ]]; then
        service_start $(_get_service_alternative $1);
    else
        error "No matching service starter found for $1";
    fi
}

# Stopping
function _service_stop_systemd() {
    systemctl daemon-reload;
    systemctl stop "$1.service";
}

function _service_stop_rc-service() {
    rc-service "$1" stop;
}

function _service_stop_initd() {
    "/etc/init.d/$1" stop;
}

function service_stop() {
    if [ -z ${1+x} ]; then
        error "Missing argument service";
        return 1;
    fi
    if hash systemctl 2>/dev/null; then # systemd
        _service_stop_systemd $@;

    elif hash rc-service 2>/dev/null; then # rc-service
        _service_stop_rc-service $(_get_service_real $1);

    elif [[ -x "/etc/init.d/$1" ]]; then # init.d
        _service_stop_initd $@;

    elif [[ "$(_get_service_alternative $1)" != "" ]]; then
        service_stop $(_get_service_alternative $1);
    else
        error "No matching service stopper found for $1";
    fi
}

# Restart
function _service_restart_systemd() {
    systemctl daemon-reload;
    systemctl restart "$1.service";
}

function _service_restart_rc-service() {
    rc-service "$1" restart;
}

function _service_restart_initd() {
    "/etc/init.d/$1" restart;
}

function service_restart() {
    if [ -z ${1+x} ]; then
        error "Missing argument service";
        return 1;
    fi

    if hash systemctl 2>/dev/null; then # systemd
        _service_restart_systemd $@;

    elif hash rc-service 2>/dev/null; then # rc-service
        _service_restart_rc-service $(_get_service_real $1);

    elif [[ -x "/etc/init.d/$1" ]]; then # init.d
        _service_restart_initd $@;

    elif [[ "$(_get_service_alternative $1)" != "" ]]; then
        service_restart $(_get_service_alternative $1);
    else
        error "No matching service restarter found for $1";
    fi
}

# Service status
function _service_status_systemd() {
    systemctl --quiet status httpd >/dev/null;
    if [[ $? -ne 0 ]]; then
        echo "down";
    else
        echo "up";
    fi
}

function _service_status_rc-service() {
    rc-service -q httpd status;
    if [[ $? -ne 0 ]]; then
        echo "down";
    else
        echo "up";
    fi
}

function _service_status_initd() {
    error "Not implemented";
    return 1;
}

function service_status() {
    if [ -z ${1+x} ]; then
        error "Missing argument service";
        return 1;
    fi

    if hash systemctl 2>/dev/null; then # systemd
        _service_status_systemd $@;

    elif hash rc-service 2>/dev/null; then # rc-service
        _service_status_rc-service $(_get_service_real $1);

    elif [[ -x "/etc/init.d/$1" ]]; then # init.d
        _service_status_initd $@;

    elif [[ "$(_get_service_alternative $1)" != "" ]]; then
        service_status $(_get_service_alternative $1);
    else
        error "Could not determine status for service $1";
    fi
}
