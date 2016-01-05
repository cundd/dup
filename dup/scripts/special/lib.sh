# --------------------------------------------------------
# File methods
# --------------------------------------------------------
function add-string-to-file-if-not-found () {
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
function get-service-alternative() {
    if [[ "$1" == "mysqld" ]]; then
        echo "mariadb";
    fi
    echo "";
}

function get-service-real() {
    if [[ "$(get-service-alternative $1)" != "" ]]; then
        echo $(get-service-alternative $1);
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
    rc-service $1 start;
}

function _start-initd-service() {
    "/etc/init.d/$1" start;
}

function start-service() {
    if hash systemctl 2>/dev/null; then # systemd
        _start-systemd-service $@;

    elif hash rc-service 2>/dev/null; then # rc-service
        get-service-real $1
        _start-rc-service-service $(get-service-real $1);

    elif [[ -x "/etc/init.d/$1" ]]; then # init.d
        _start-initd-service $@;

    elif [[ "$(get-service-alternative $1)" != "" ]]; then
        start-service $(get-service-alternative $1);
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
    rc-service $1 stop;
}

function _stop-initd-service() {
    "/etc/init.d/$1" stop;
}

function stop-service() {
    if hash systemctl 2>/dev/null; then # systemd
        _stop-systemd-service $@;

    elif hash rc-service 2>/dev/null; then # rc-service
        _stop-rc-service-service $(get-service-real $1);

    elif [[ -x "/etc/init.d/$1" ]]; then # init.d
        _stop-initd-service $@;

    elif [[ "$(get-service-alternative $1)" != "" ]]; then
        stop-service $(get-service-alternative $1);
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
    rc-service $1 restart;
}

function _restart-initd-service() {
    "/etc/init.d/$1" restart;
}

function restart-service() {
    if hash systemctl 2>/dev/null; then # systemd
        _restart-systemd-service $@;

    elif hash rc-service 2>/dev/null; then # rc-service
        _restart-rc-service-service $(get-service-real $1);

    elif [[ -x "/etc/init.d/$1" ]]; then # init.d
        _restart-initd-service $@;

    elif [[ "$(get-service-alternative $1)" != "" ]]; then
        restart-service $(get-service-alternative $1);
    else
        >&2 echo "No matching service restarter found for $1";
    fi
}
