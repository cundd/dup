# --------------------------------------------------------
# Service methods
# --------------------------------------------------------

# --------------------------------------------------------
# Service available
function duplib::_service_exists_systemd() {
    systemctl daemon-reload;
    systemctl list-units        |grep -q "\s$1$" && echo "true" || echo "false";

}

function duplib::_service_exists_rc-service() {
    rc-service --list           |grep -q "\s$1$" && echo "true" || echo "false";
}

function duplib::_service_exists_service() {
    service --status-all 2>&1   |grep -q "\s$1$" && echo "true" || echo "false";
}

function duplib::_service_exists_initd() {
    test -e "/etc/init.d/$1" && echo "true" || echo "false";
}

function duplib::service_exists() {
    if [ -z ${1+x} ]; then
        duplib::error "Missing argument service";
        return 1;
    fi

    if hash systemctl 2>/dev/null; then # systemd
        duplib::_service_exists_systemd $1;

    elif hash rc-service 2>/dev/null; then # rc-service
        duplib::_service_exists_rc-service $1;

    elif hash service 2>/dev/null; then # service
        duplib::_service_exists_service $1;

    elif [[ -x "/etc/init.d/$1" ]]; then # init.d
        duplib::_service_exists_initd $1;

    else
        duplib::error "No matching service tester found for $1";
        return 1;
    fi
}


# --------------------------------------------------------
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

    duplib::_find_service_method_implementation "service_start" $1;
}


# --------------------------------------------------------
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

    duplib::_find_service_method_implementation "service_stop" $1;
}


# --------------------------------------------------------
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

    duplib::_find_service_method_implementation "service_restart" $1;
}


# --------------------------------------------------------
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

    duplib::_find_service_method_implementation "service_status" $1;
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


# --------------------------------------------------------
# Service name transformation
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

function duplib::_transform_service_names_alpine() {
    if [[ "$1" == "httpd" ]]; then
        echo "apache2";
    fi
    echo "$1";
}

function duplib::_transform_service_names() {
    if [ -z ${1+x} ]; then
        error "Please specify the service name";
        return 1;
    fi

    local os_identifier=$(duplib::get_dup_linux_distribution_specific_folder);
    if type "duplib::_transform_service_names_$os_identifier" &> /dev/null; then
        "duplib::_transform_service_names_$os_identifier" $@;
    else
        echo "$1";
    fi
}


# --------------------------------------------------------
# Invoke the right tool for the platfrom
function duplib::_find_service_method_implementation() {
    if [ -z ${1+x} ]; then
        duplib::error "Missing argument 1 (method)";
        return 1;
    fi
    if [ -z ${2+x} ]; then
        duplib::error "Missing argument 2 (service)";
        return 1;
    fi

    local method="$1";
    local service=$(duplib::_transform_service_names $2);

    if [[ "$(duplib::service_exists $service)" != "true" ]]; then
        if [[ "$(duplib::_get_service_alternative $service)" != "" ]]; then
            duplib::$method $(duplib::_get_service_alternative $service);
        else
            duplib::error "Service $service does not exist and no alternative names can be found";
            return 1;
        fi
        return;
    fi

    if hash systemctl 2>/dev/null; then # systemd
        "duplib::_$method"_systemd $service;

    elif hash rc-service 2>/dev/null; then # rc-service
        "duplib::_$method"_rc-service $service;

    elif hash service 2>/dev/null; then # service
        "duplib::_$method"_service $service;

    elif [[ -x "/etc/init.d/$service" ]]; then # init.d
        "duplib::_$method"_initd $service;

    else
        duplib::error "No matching implementation found for method $method and service $1";
        return 1;
    fi
}
