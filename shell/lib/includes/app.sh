# --------------------------------------------------------
# Package management
# --------------------------------------------------------
function duplib::app_install() {
    if [[ $# -gt 0 ]] && [[ "$1" == "-y" ]]; then
        DUP_LIB_APP_NONINTERACTIVE="true";
        shift;
    elif [[ -z ${DUP_LIB_APP_NONINTERACTIVE+x} ]]; then
        DUP_LIB_APP_NONINTERACTIVE="false";
    fi

    if hash pacman 2>/dev/null; then
        duplib::_app_install_with_pacman $(duplib::transform_app_names $@);
    elif hash apk 2>/dev/null; then
        duplib::_app_install_with_apk $(duplib::transform_app_names $@);
    elif hash yum 2>/dev/null; then
        duplib::_app_install_with_yum $(duplib::transform_app_names $@);
    elif hash apt-get 2>/dev/null; then
        duplib::_app_install_with_apt-get $(duplib::transform_app_names $@);
    else
        error "No matching installer for platform $(duplib::detect_os) found";
        return 103;
    fi
}

function duplib::app_search() {
    if hash pacman 2>/dev/null; then
        duplib::_app_search_with_pacman $(duplib::transform_app_names $@);
    elif hash apk 2>/dev/null; then
        duplib::_app_search_with_apk $(duplib::transform_app_names $@);
    elif hash yum 2>/dev/null; then
        duplib::_app_search_with_yum $(duplib::transform_app_names $@);
    elif hash apt-get 2>/dev/null; then
        duplib::_app_search_with_apt-get $(duplib::transform_app_names $@);
    else
        error "No matching installer for platform $(duplib::detect_os) found";
        return 103;
    fi
}

function duplib::system_upgrade() {
    if [[ $# -gt 0 ]] && [[ "$1" == "-y" ]]; then
        DUP_LIB_APP_NONINTERACTIVE="true";
        shift;
    elif [[ -z ${DUP_LIB_APP_NONINTERACTIVE+x} ]]; then
        DUP_LIB_APP_NONINTERACTIVE="false";
    fi

    if hash pacman 2>/dev/null; then
        duplib::_system_upgrade_with_pacman "$@";
    elif hash apk 2>/dev/null; then
        duplib::_system_upgrade_with_apk "$@";
    elif hash yum 2>/dev/null; then
        duplib::_system_upgrade_with_yum "$@";
    elif hash apt-get 2>/dev/null; then
        duplib::_system_upgrade_with_apt-get "$@";
    else
        error "No matching updater for platform $(duplib::detect_os) found";
        return 103;
    fi
}


# --------------------------------------------------------
# Private methods
# --------------------------------------------------------
function duplib::_transform_app_names_general() {
    local allPackages=$@;
    echo $allPackages;
}

function duplib::_transform_app_names_ubuntu() {
    local allPackages=$@;

    # Replace app names
    allPackages=$(echo $allPackages | sed 's/\bapache\b/apache2/g')                 # apache => apache2
    allPackages=$(echo $allPackages | sed 's/\bphp-mysqli\b/php5-mysql/g')          # php-mysqli => php5-mysql
    allPackages=$(echo $allPackages | sed 's/\bphp\-\b/php5-/g')                    # php- => php5-
    allPackages=$(echo $allPackages | sed 's/\bmysql-server\b/mariadb-server/g')    # mysql-server => mariadb-server
    allPackages=$(echo $allPackages | sed 's/\bmysql-client\b/mariadb-client/g')    # mysql-client => mariadb-client

    local arrayOfPackagesToRemoveFromList="apache2-proxy
php5-pdo_mysql
php5-soap
php5-opcache
php5-xml
php5-zip
php5-zlib
php5-openssl
php5-xmlreader
php5-ctype
php5-calendar
php5-phar
php5-iconv";

    for appToRemoveFromList in $arrayOfPackagesToRemoveFromList; do
        allPackages=$(echo $allPackages | sed "s/\b$appToRemoveFromList\b//g");
    done

    # Install php5-cli if other PHP apps are installed
    if [[ $allPackages == *php5-* ]]; then
        allPackages="$allPackages php5-cli";
    fi

    # Install MySQL Server in a Non-Interactive mode. Default root password will be "root"
    if [[ $allPackages == *mariadb-* ]]; then

        echo "mysql-server-5.6 mysql-server/root_password password root" | debconf-set-selections
        echo "mysql-server-5.6 mysql-server/root_password_again password root" | debconf-set-selections
    fi

    # Install libapache2-mod-fastcgi if Apache is installed
    if [[ $allPackages == *apache2* ]]; then
        allPackages="$allPackages libapache2-mod-fastcgi";
    fi

    echo $allPackages;
}

function duplib::_transform_app_names_alpine() {
    local allPackages=$@;

    # Replace app names
    allPackages=$(echo $allPackages | sed 's/\bapache\b/apache2/g')             # apache => apache2
    allPackages=$(echo $allPackages | sed 's/\bmysql-server\b/mysql/g')         # mysql-server => mysql
    allPackages=$(echo $allPackages | sed 's/\bgraphicsmagick\b/imagemagick/g') # graphicsmagick => imagemagick
    allPackages=$(echo $allPackages | sed 's/\bbuild-essential\b/alpine-sdk/g') # build-essential => alpine-sdk

    echo $allPackages;
}

function duplib::_transform_app_names_arch() {
    local allPackages=$@;

    # Replace package names
    allPackages=$(echo $allPackages | sed 's/\bmysql-server\b/mariadb/g')           # mysql-server => mariadb
    allPackages=$(echo $allPackages | sed 's/\bmysql-client\b/mariadb-clients/g')   # mysql-client => mariadb-clients
    allPackages=$(echo $allPackages | sed 's/\bbuild-essential\b/base-devel/g')     # build-essential => base-devel

    local arrayOfPackagesToRemoveFromList="apache-proxy
php-mysqli
php-pdo_mysql
php-soap
php-opcache
php-json
php-curl
php-xml
php-zip
php-zlib
php-openssl
php-xmlreader
php-ctype
php-calendar
php-phar
php-iconv
";

    for packageToRemoveFromList in $arrayOfPackagesToRemoveFromList; do
        allPackages=$(echo $allPackages | sed "s/\b$packageToRemoveFromList\b//g");
    done

    echo $allPackages;
}

function duplib::transform_app_names() {
    if [ -z ${1+x} ]; then
        error "Please specify at least one app";
        return 1;
    fi

    if type "duplib::_transform_app_names_$(duplib::get_os_specific_folder)" &> /dev/null; then
        "duplib::_transform_app_names_$(duplib::get_os_specific_folder)" $@;
    else
        duplib::_transform_app_names_general $@;
    fi
}

# --------------------------------------------------------
# Installation
function duplib::_app_install_with_pacman() {
    for application in "$@"; do
        duplib::info "Install application: '$application'";
        if [[ "$DUP_LIB_APP_NONINTERACTIVE" == "true" ]]; then
            pacman -S --noconfirm --needed "$application";
        else
            pacman -S --needed "$application";
        fi
    done
}

function duplib::_app_install_with_apk() {
    for application in "$@"; do
        duplib::info "Install application: '$application'";
        apk add $application;
    done
}

function duplib::_app_install_with_yum() {
    for application in "$@"; do
        duplib::info "Install application: '$application'";
        if [[ "$DUP_LIB_APP_NONINTERACTIVE" == "true" ]]; then
            yum -y install "$application";
        else
            yum install "$application";
        fi
    done
}

function duplib::_app_install_with_apt-get() {
    duplib::_app_apt-get_update;

    for application in "$@"; do
        duplib::info "Install application: '$application'";
        if [[ "$DUP_LIB_APP_NONINTERACTIVE" == "true" ]]; then
            DEBIAN_FRONTEND=noninteractive apt-get -y install "$application";
        else
            apt-get install "$application";
        fi
    done
}

# --------------------------------------------------------
# Search
function duplib::_app_search_with_pacman() {
    pacman -Ss "$@";
}

function duplib::_app_search_with_apk() {
    apk search "$@";
}

function duplib::_app_search_with_yum() {
    yum search "$@";
}

function duplib::_app_search_with_apt-get() {
    apt-cache search "$@";
}

# --------------------------------------------------------
# Updates
function duplib::_system_upgrade_with_pacman() {
    if [[ "$DUP_LIB_APP_NONINTERACTIVE" == "true" ]]; then
        # System upgrade
        pacman -Syu --noconfirm;

        # Remove orphans
        if [[ "$(pacman -Qtdq)" != "" ]]; then
            pacman -Rns --noconfirm $(pacman -Qtdq);
        fi

        # Remove cache
        pacman -Sc --noconfirm;
    else
        # System upgrade
        pacman -Syu;

        # Remove orphans
        if [[ "$(pacman -Qtdq)" != "" ]]; then
            pacman -Rns $(pacman -Qtdq);
        fi

        # Remove cache
        pacman -Sc;
    fi
}

function duplib::_system_upgrade_with_apk() {
    apk update;
    apk upgrade;
}

function duplib::_system_upgrade_with_yum() {
    error "Not implemented yet";
}

function duplib::_system_upgrade_with_apt-get() {
    if [[ "$DUP_LIB_APP_NONINTERACTIVE" == "true" ]]; then
        duplib::_app_apt-get_update;
        DEBIAN_FRONTEND=noninteractive apt-get -y upgrade;
    else
        duplib::_app_apt-get_update;
        apt-get upgrade;
    fi
}

# --------------------------------------------------------
# Helpers
function duplib::_app_apt-get_update() {
    : ${APT_PACKAGE_LIST_UPDATED="false"};
    if [[ "$APT_PACKAGE_LIST_UPDATED" != "true" ]]; then
        apt-get update;
        APT_PACKAGE_LIST_UPDATED="true";
    fi
}
