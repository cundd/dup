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
    if [ -f "/etc/SUSE-release" ];          then distribution="Novell SUSE"; fi
    if [ -f "/etc/redhat-release," ];       then distribution="Red Hat"; fi
    if [ -f "/etc/fedora-release" ];        then distribution="Fedora"; fi
    if [ -f "/etc/slackware-release," ];    then distribution="Slackware"; fi
    if [ -f "/etc/debian_release," ];       then distribution="Debian"; fi
    if [ -f "/etc/mandrake-release" ];      then distribution="Mandrake"; fi
    if [ -f "/etc/yellowdog-release" ];     then distribution="Yellow dog"; fi
    if [ -f "/etc/sun-release" ];           then distribution="Sun JDS"; fi
    if [ -f "/etc/release" ];               then distribution="Solaris/Sparc"; fi
    if [ -f "/etc/gentoo-release" ];        then distribution="Gentoo"; fi
    if [ -f "/etc/UnitedLinux-release" ];   then distribution="UnitedLinux"; fi
    if [ -f "/etc/lsb-release" ];           then distribution="ubuntu"; fi

    echo $distribution;
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
        >&2 echo "Missing argument service";
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
        >&2 echo "No matching service starter found for $1";
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
        >&2 echo "Missing argument service";
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
        >&2 echo "No matching service stopper found for $1";
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
        >&2 echo "Missing argument service";
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
        >&2 echo "No matching service restarter found for $1";
    fi
}
