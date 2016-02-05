#!/bin/bash
#
# Plugin to create packages
set -o nounset
set -o errexit

# --------------------------------------------------------
# Commands
# --------------------------------------------------------

# Package the database and files into a compressed TAR package
function dupcli::package::pack() {
    if [[ $(dupcli::is_guest) == "yes" ]]; then
        dupcli::_package::guest::package "$@";
    elif [[ -e "$DUP_PROJECT_BASE/.vagrant/machines/default/virtualbox/id" ]]; then
        dupcli::_package::vagrant::package "$@";
    else
        duplib::fatal_error "No supported way to package found";
    fi
}

# Unpack a package
function dupcli::package::unpack() {
    if [ "$#" -lt 1 ]; then
        duplib::fatal_error "Missing argument 1 (package_file)";
    fi
    duplib::check_required_command "tar";
    duplib::check_required_command "gzip";

    local package_file="$1";

    # Unpack the package
    tar -xzf "$package_file";

    echo "SQL file database.sql.gz";
    # dupcli::mysql::dump "$dup_remote_path/database.sql.gz" > /dev/null;

    # Package the files
    echo "Unpack the files";
    tar -xf "httpdocs.tar";
    rm "httpdocs.tar";
}

# --------------------------------------------------------
# Guest
# --------------------------------------------------------
function dupcli::_package::guest::package() {
    if [ "$#" -lt 1 ]; then
        duplib::fatal_error "When run on the guest the name for the package must be given";
    fi
    duplib::check_required_command "tar";
    duplib::check_required_command "gzip";

    local package_name="$1";
    local dup_remote_path="/vagrant/.package/$package_name";

    # Package MySQL database
    echo "Export database";
    dupcli::mysql::dump "$dup_remote_path/database.sql.gz" > /dev/null;

    # Package the files
    echo "Package the files";
    local vhost_document_root="$(duplib::get_vhost_document_root)";
    cd "$vhost_document_root";

    tar -cf "$dup_remote_path/httpdocs.tar" ".";
}

# --------------------------------------------------------
# Vagrant adapter
# --------------------------------------------------------
function dupcli::_package::vagrant::package() {
    duplib::check_required_command "tar";
    duplib::check_required_command "gzip";

    local package_name="package-$(date +%F-%H-%M-%S)";
    local dup_local_path="$DUP_PROJECT_BASE/.package/$package_name";
    local dup_package_local_path="$dup_local_path.tar.gz";
    local current_directory="`pwd`";

    if [ "$#" -gt 0 ] && [ "$1" != "" ]; then
        dup_package_local_path="$1";

        if [ "${dup_package_local_path:0:1}" != "/" ]; then
            dup_package_local_path="$current_directory/$dup_package_local_path";
        fi

        if [ -e "$dup_package_local_path" ]; then
            duplib::fatal_error "Package $dup_package_local_path already exists. Will not proceed";
        fi
    fi

    if [ ! -w "$dup_package_local_path" ] && [ ! -w "$(dirname $dup_package_local_path)" ]; then
        duplib::fatal_error "Cannot write to $dup_package_local_path";
    fi

    dupcli::ssh::execute "dup package::pack $package_name";

    # Package all files
    cd "$dup_local_path";
    tar -czf "$dup_package_local_path" "." 2> /dev/null || {
        duplib::error "Could not compress package to $dup_package_local_path";
        duplib::error "Leaving files in $dup_local_path";
        return 1;
    }
    cd "$current_directory";

    if [ -e "$dup_package_local_path" ]; then
        echo "Created package at $dup_package_local_path";

        # Remove the temporary files
        rm -r "$dup_local_path";
    else
        duplib::error "Error creating package at $dup_package_local_path";
        return 1;
    fi
}
