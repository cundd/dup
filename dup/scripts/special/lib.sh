# --------------------------------------------------------
# Helpers
# --------------------------------------------------------
function error() {
    >& 2 echo "$@";
}

# --------------------------------------------------------
# HTTP/Apache methods
# --------------------------------------------------------
function _document-root() {
    echo "/var/www/dup.cundd.net/htdocs";
}

function detect-and-set-document-root() {
    local apacheBasePath="/etc";

    if [[ -e "/etc/apache2/" ]]; then
        apacheBasePath="/etc/apache2";
    elif [[ -e "/etc/httpd/conf/" ]]; then
        apacheBasePath="/etc/httpd/conf";
    fi

    local apacheConfFile=$(grep -lir '^DocumentRoot' $apacheBasePath|head -n1);

    add-string-to-file-if-not-found "DocumentRoot \"$(_document-root)\"" $apacheConfFile;
    detect-document-root;
}

function detect-document-root() {
    # local apacheBasePath="/etc";
    #
    # if [[ -e "/etc/apache2/" ]]; then
    #     apacheBasePath="/etc/apache2";
    # elif [[ -e "/etc/httpd/conf/" ]]; then
    #     apacheBasePath="/etc/httpd/conf";
    # fi
    #echo $(grep -hir '^DocumentRoot' $apacheBasePath|head -n1|awk '/^DocumentRoot/{gsub("\"", ""); print $2}')
    _document-root;
}

function get-vhost-document-root() {
    echo "/var/www/dup.cundd.net/htdocs";
}

function detect-apache-configuration-file() {
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
function detect-linux-distribution() {
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

function get-linux-distribution-release-file() {
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

function get-dup-linux-distribution-specific-folder() {
    basename `get-linux-distribution-release-file` | sed 's/release//' | sed 's/[-_]//'| tr '[:upper:]' '[:lower:]';
}

function copy-linux-distribution-specific-file() {
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
    if [[ -e "$dupFilesPath/$(get-dup-linux-distribution-specific-folder)/$fileName" ]]; then
        cp "$dupFilesPath/$(get-dup-linux-distribution-specific-folder)/$fileName" "$destination";
    elif [[ -e "$dupFilesPath/general/$fileName" ]]; then # Copy the default file
        cp "$dupFilesPath/general/$fileName" "$destination";
    else
        error "No distribution specific or general file $fileName found $(get-dup-linux-distribution-specific-folder)";
        return 1;
    fi
}

# --------------------------------------------------------
# File methods
# --------------------------------------------------------
function add-string-to-file-if-not-found() {
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
function _get-service-alternative() {
    if [[ "$1" == "mysqld" ]]; then
        echo "mariadb";
    fi
    echo "";
}

function _get-service-real() {
    if [[ "$(_get-service-alternative $1)" != "" ]]; then
        echo $(_get-service-alternative $1);
    else
        echo "$1";
    fi
}

# Starting
function _start-systemd-service() {
    systemctl daemon-reload;
    systemctl start "$1.service";
}

function _start-rc-service-service() {
    rc-service "$1" start;
}

function _start-initd-service() {
    "/etc/init.d/$1" start;
}

function start-service() {
    if [ -z ${1+x} ]; then
        error "Missing argument service";
        return 1;
    fi

    if hash systemctl 2>/dev/null; then # systemd
        _start-systemd-service $@;

    elif hash rc-service 2>/dev/null; then # rc-service
        _get-service-real $1
        _start-rc-service-service $(_get-service-real $1);

    elif [[ -x "/etc/init.d/$1" ]]; then # init.d
        _start-initd-service $@;

    elif [[ "$(_get-service-alternative $1)" != "" ]]; then
        start-service $(_get-service-alternative $1);
    else
        error "No matching service starter found for $1";
    fi
}

# Stopping
function _stop-systemd-service() {
    systemctl daemon-reload;
    systemctl stop "$1.service";
}

function _stop-rc-service-service() {
    rc-service "$1" stop;
}

function _stop-initd-service() {
    "/etc/init.d/$1" stop;
}

function stop-service() {
    if [ -z ${1+x} ]; then
        error "Missing argument service";
        return 1;
    fi
    if hash systemctl 2>/dev/null; then # systemd
        _stop-systemd-service $@;

    elif hash rc-service 2>/dev/null; then # rc-service
        _stop-rc-service-service $(_get-service-real $1);

    elif [[ -x "/etc/init.d/$1" ]]; then # init.d
        _stop-initd-service $@;

    elif [[ "$(_get-service-alternative $1)" != "" ]]; then
        stop-service $(_get-service-alternative $1);
    else
        error "No matching service stopper found for $1";
    fi
}

# Restart
function _restart-systemd-service() {
    systemctl daemon-reload;
    systemctl restart "$1.service";
}

function _restart-rc-service-service() {
    rc-service "$1" restart;
}

function _restart-initd-service() {
    "/etc/init.d/$1" restart;
}

function restart-service() {
    if [ -z ${1+x} ]; then
        error "Missing argument service";
        return 1;
    fi

    if hash systemctl 2>/dev/null; then # systemd
        _restart-systemd-service $@;

    elif hash rc-service 2>/dev/null; then # rc-service
        _restart-rc-service-service $(_get-service-real $1);

    elif [[ -x "/etc/init.d/$1" ]]; then # init.d
        _restart-initd-service $@;

    elif [[ "$(_get-service-alternative $1)" != "" ]]; then
        restart-service $(_get-service-alternative $1);
    else
        error "No matching service restarter found for $1";
    fi
}

# Service status
function _service-status-systemd() {
    systemctl --quiet status httpd >/dev/null;
    if [[ $? -ne 0 ]]; then
        echo "down";
    else
        echo "up";
    fi
}

function _service-status-rc-service() {
    rc-service -q httpd status;
    if [[ $? -ne 0 ]]; then
        echo "down";
    else
        echo "up";
    fi
}

function _service-status-initd() {
    error "Not implemented";
    return 1;
}

function service-status() {
    if [ -z ${1+x} ]; then
        error "Missing argument service";
        return 1;
    fi

    if hash systemctl 2>/dev/null; then # systemd
        _service-status-systemd $@;

    elif hash rc-service 2>/dev/null; then # rc-service
        _service-status-rc-service $(_get-service-real $1);

    elif [[ -x "/etc/init.d/$1" ]]; then # init.d
        _service-status-initd $@;

    elif [[ "$(_get-service-alternative $1)" != "" ]]; then
        service-status $(_get-service-alternative $1);
    else
        error "Could not determine status for service $1";
    fi
}
