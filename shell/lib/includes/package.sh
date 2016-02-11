function duplib::package_install() {
    duplib::warn "Deprecated use duplib::app_install instead";
    duplib::app_install "$@";
}

function duplib::package_search() {
    duplib::warn "Deprecated use duplib::app_search instead";
    duplib::app_search "$@";
}

function duplib::transform_package_names() {
    duplib::warn "Deprecated use duplib::transform_app_names instead";
    duplib::transform_app_names "$@";
}
