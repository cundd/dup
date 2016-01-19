# --------------------------------------------------------
# Service methods
# --------------------------------------------------------
function duplib::_get_service_alternative() {
    case "$1" in
        mysqld)
            echo "mysql"
            ;;
        mysql)
            echo "mariadb"
            ;;

        httpd)
            echo "apache2"
            ;;

        php-fpm)
            echo "php5-fpm"
            ;;

        *)
            echo ""
    esac
}

function duplib::_get_service_real() {
    if [[ "$(duplib::_get_service_alternative $1)" != "" ]]; then
        echo $(duplib::_get_service_alternative $1);
    else
        echo "$1";
    fi
}

# Starting
function duplib::_service_start_systemd() {
    systemctl daemon-reload;
    systemctl start "$1.service";
}

function duplib::_service_start_rc-service() {
    rc-service "$1" start;
}

function duplib::_service_start_service() {
    service "$1" start;
}

function duplib::_service_start_initd() {
    "/etc/init.d/$1" start;
}

function duplib::service_start() {
    if [ -z ${1+x} ]; then
        duplib::error "Missing argument service";
        return 1;
    fi

    if hash systemctl 2>/dev/null; then # systemd
        duplib::_service_start_systemd $@;

    elif hash service 2>/dev/null; then # service
        duplib::_service_start_service $(duplib::_get_service_real $1);

    elif hash rc-service 2>/dev/null; then # rc-service
        duplib::_service_start_rc-service $(duplib::_get_service_real $1);

    elif [[ -x "/etc/init.d/$1" ]]; then # init.d
        duplib::_service_start_initd $@;

    elif [[ "$(duplib::_get_service_alternative $1)" != "" ]]; then
        duplib::service_start $(duplib::_get_service_alternative $1);
    else
        duplib::error "No matching service starter found for $1";
        return 1;
    fi
}

# Stopping
function duplib::_service_stop_systemd() {
    systemctl daemon-reload;
    systemctl stop "$1.service";
}

function duplib::_service_stop_rc-service() {
    rc-service "$1" stop;
}

function duplib::_service_stop_service() {
    service "$1" stop;
}

function duplib::_service_stop_initd() {
    "/etc/init.d/$1" stop;
}

function duplib::service_stop() {
    if [ -z ${1+x} ]; then
        duplib::error "Missing argument service";
        return 1;
    fi
    if hash systemctl 2>/dev/null; then # systemd
        duplib::_service_stop_systemd $@;

    elif hash service 2>/dev/null; then # service
        duplib::_service_stop_service $(duplib::_get_service_real $1);

    elif hash rc-service 2>/dev/null; then # rc-service
        duplib::_service_stop_rc-service $(duplib::_get_service_real $1);

    elif [[ -x "/etc/init.d/$1" ]]; then # init.d
        duplib::_service_stop_initd $@;

    elif [[ "$(duplib::_get_service_alternative $1)" != "" ]]; then
        echo "Try alternative service name $(duplib::_get_service_alternative $1)";
        duplib::service_stop $(duplib::_get_service_alternative $1);
    else
        duplib::error "No matching service stopper found for $1";
        return 1;
    fi
}

# Restart
function duplib::_service_restart_systemd() {
    systemctl daemon-reload;
    systemctl restart "$1.service";
}

function duplib::_service_restart_rc-service() {
    rc-service "$1" restart;
}

function duplib::_service_restart_service() {
    service "$1" restart;
}

function duplib::_service_restart_initd() {
    "/etc/init.d/$1" restart;
}

function duplib::service_restart() {
    if [ -z ${1+x} ]; then
        duplib::error "Missing argument service";
        return 1;
    fi

    if hash systemctl 2>/dev/null; then # systemd
        duplib::_service_restart_systemd $@;

    elif hash service 2>/dev/null; then # service
        duplib::_service_restart_service $(duplib::_get_service_real $1);

    elif hash rc-service 2>/dev/null; then # rc-service
        duplib::_service_restart_rc-service $(duplib::_get_service_real $1);

    elif [[ -x "/etc/init.d/$1" ]]; then # init.d
        duplib::_service_restart_initd $@;

    elif [[ "$(duplib::_get_service_alternative $1)" != "" ]]; then
        echo "Try alternative service name $(duplib::_get_service_alternative $1)";
        duplib::service_restart $(duplib::_get_service_alternative $1);
    else
        duplib::error "No matching service restarter found for $1";
        return 1;
    fi
}

# Service status
function duplib::_service_status_systemd() {
    systemctl --quiet status "$1" >/dev/null;
    if [[ $? -ne 0 ]]; then
        echo "down";
    else
        echo "up";
    fi
}

function duplib::_service_status_rc-service() {
    rc-service -q "$1" status && echo "up" || echo "down";
}

function duplib::_service_status_rc-service() {
    service -q "$1" status && echo "up" || echo "down";
}

function duplib::_service_status_initd() {
    duplib::error "Not implemented";
    return 1;
}

function duplib::service_status() {
    if [ -z ${1+x} ]; then
        duplib::error "Missing argument service";
        return 1;
    fi

    if hash systemctl 2>/dev/null; then # systemd
        duplib::_service_status_systemd $@;

    elif hash service 2>/dev/null; then # service
        duplib::_service_status_service $(duplib::_get_service_real $1);

    elif hash rc-service 2>/dev/null; then # rc-service
        duplib::_service_status_rc-service $(duplib::_get_service_real $1);

    elif [[ -x "/etc/init.d/$1" ]]; then # init.d
        duplib::_service_status_initd $@;

    elif [[ "$(duplib::_get_service_alternative $1)" != "" ]]; then
        duplib::service_status $(duplib::_get_service_alternative $1);
    else
        duplib::error "Could not determine status for service $1";
        return 1;
    fi
}

function duplib::service_is_up() {
    if [ -z ${1+x} ]; then
        duplib::error "Missing argument service";
        return 2;
    fi

    if [[ $(duplib::service_status $1) == "up" ]]; then
        return 0;
    else
        return 1;
    fi
}

function duplib::service_is_down() {
    if [ -z ${1+x} ]; then
        duplib::error "Missing argument service";
        return 2;
    fi

    if [[ $(duplib::service_status $1) == "down" ]]; then
        return 0;
    else
        return 1;
    fi
}

function duplib::service_start_if_down() {
    duplib::service_is_up $1 || duplib::service_start $@;
}

function duplib::service_stop_if_running() {
    duplib::service_is_down $1 || duplib::service_stop $@;
}
