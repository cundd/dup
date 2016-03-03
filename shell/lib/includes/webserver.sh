# --------------------------------------------------------
# HTTP/Apache methods
# --------------------------------------------------------

# Returns the vhost base directory
function duplib::get_vhost_base() {
    echo "/var/www/vhosts/dup.cundd.net";
}

# Returns the vhost document root
function duplib::get_vhost_document_root() {
    echo "$(duplib::get_vhost_base)/httpdocs";
}

# Returns the Apache configuration file path
function duplib::detect_apache_configuration_file() {
    if [[ -e "/etc/apache2/httpd.conf" ]]; then
        echo "/etc/apache2/httpd.conf";
    elif [[ -e "/etc/apache2/apache2.conf" ]]; then
        echo "/etc/apache2/apache2.conf";
    elif [[ -e "/etc/httpd/conf/httpd.conf" ]]; then
        echo "/etc/httpd/conf/httpd.conf";
    else
        local confFile=$(find /etc -name "httpd.conf"|head -n1);
        if [[ "$confFile" == "" ]]; then
            duplib::error "Could not find apache configuration file";
            return 1;
        fi
    fi
}
