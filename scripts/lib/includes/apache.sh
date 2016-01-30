# --------------------------------------------------------
# HTTP/Apache methods
# --------------------------------------------------------
function duplib::_document_root() {
    echo "/var/www/vhosts/dup.cundd.net/httpdocs";
}

function duplib::detect_and_set_document_root() {
    local apacheBasePath="/etc";

    if [[ -e "/etc/apache2/" ]]; then
        apacheBasePath="/etc/apache2";
    elif [[ -e "/etc/httpd/conf/" ]]; then
        apacheBasePath="/etc/httpd/conf";
    fi

    local apacheConfFile=$(grep -lir '^DocumentRoot' $apacheBasePath|head -n1);

    duplib::add_string_to_file_if_not_found "DocumentRoot \"$(_document_root)\"" $apacheConfFile;
    duplib::detect_document_root;
}

function duplib::detect_document_root() {
    # local apacheBasePath="/etc";
    #
    # if [[ -e "/etc/apache2/" ]]; then
    #     apacheBasePath="/etc/apache2";
    # elif [[ -e "/etc/httpd/conf/" ]]; then
    #     apacheBasePath="/etc/httpd/conf";
    # fi
    #echo $(grep -hir '^DocumentRoot' $apacheBasePath|head -n1|awk '/^DocumentRoot/{gsub("\"", ""); print $2}')
    duplib::_document_root;
}

function duplib::get_vhost_document_root() {
    echo "/var/www/vhosts/dup.cundd.net/httpdocs";
}

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
