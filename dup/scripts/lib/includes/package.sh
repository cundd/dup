# --------------------------------------------------------
# Package management
# --------------------------------------------------------
function duplib::_package_install_with_pacman() {
    local allPackages=$@;
    pacman -S --noconfirm --needed $allPackages;
}

function duplib::_package_install_with_apk() {
    local allPackages=$@;

    # Replace package names
    allPackages=$(echo $allPackages | sed 's/\bapache\b/apache2/g')             # apache => apache2
    allPackages=$(echo $allPackages | sed 's/\bgraphicsmagick\b/imagemagick/g') # graphicsmagick => imagemagick
    apk add $allPackages;
}

function duplib::_package_install_with_yum() {
    error "Not implemented yet";
}


function duplib::package_install() {
    if hash pacman 2>/dev/null; then
        duplib::_package_install_with_pacman $@;
    elif hash apk 2>/dev/null; then
        duplib::_package_install_with_apk $@;
    elif hash yum 2>/dev/null; then
        duplib::_package_install_with_yum $@;
    else
        error "No matching installer found";
    fi
}

function duplib::_system_upgrade_with_pacman() {
    # System upgrade
    pacman -Syu --noconfirm;

    # Remove orphans
    if [[ "$(pacman -Qtdq)" != "" ]]; then
        pacman -Rns --noconfirm $(pacman -Qtdq);
    fi

    # Remove cache
    pacman -Sc --noconfirm;
}

function duplib::_system_upgrade_with_apk() {
    apk update
    apk upgrade

}

function duplib::_system_upgrade_with_yum() {
    error "Not implemented yet";
}

function duplib::system_upgrade() {
    if hash pacman 2>/dev/null; then
        duplib::_system_upgrade_with_pacman;
    elif hash apk 2>/dev/null; then
        duplib::_system_upgrade_with_apk;
    elif hash yum 2>/dev/null; then
        duplib::_system_upgrade_with_yum;
    else
        error "No matching updater found";
    fi
}
