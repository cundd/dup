# --------------------------------------------------------
# OS/Linux methods
# --------------------------------------------------------
function duplib::detect_linux_distribution() {
    case $(duplib::get_linux_distribution_release_file 2> /dev/null) in
        '/etc/SUSE-release')          echo "Novell SUSE";;
        '/etc/redhat-release')        echo "Red Hat";;
        '/etc/fedora-release')        echo "Fedora";;
        '/etc/slackware-release')     echo "Slackware";;
        '/etc/debian_release')        echo "Debian";;
        '/etc/mandrake-release')      echo "Mandrake";;
        '/etc/yellowdog-release')     echo "Yellow dog";;
        '/etc/sun-release')           echo "Sun JDS";;
        '/etc/release')               echo "Solaris/Sparc";;
        '/etc/gentoo-release')        echo "Gentoo";;
        '/etc/UnitedLinux-release')   echo "UnitedLinux";;
        '/etc/lsb-release')           echo "Ubuntu";;
        '/etc/alpine-release')        echo "Alpine";;
        '/etc/arch-release')          echo "Arch Linux";;
        '/etc/os-release')            echo "Debian";; # Is this correct?
        *) uname;;
    esac
}

function duplib::get_linux_distribution_release_file() {
    if   [ -f "/etc/SUSE-release" ];          then echo "/etc/SUSE-release";
    elif [ -f "/etc/redhat-release" ];        then echo "/etc/redhat-release";
    elif [ -f "/etc/fedora-release" ];        then echo "/etc/fedora-release";
    elif [ -f "/etc/slackware-release" ];     then echo "/etc/slackware-release";
    elif [ -f "/etc/debian_release" ];        then echo "/etc/debian_release";
    elif [ -f "/etc/mandrake-release" ];      then echo "/etc/mandrake-release";
    elif [ -f "/etc/yellowdog-release" ];     then echo "/etc/yellowdog-release";
    elif [ -f "/etc/sun-release" ];           then echo "/etc/sun-release";
    elif [ -f "/etc/release" ];               then echo "/etc/release" ];
    elif [ -f "/etc/gentoo-release" ];        then echo "/etc/gentoo-release";
    elif [ -f "/etc/UnitedLinux-release" ];   then echo "/etc/UnitedLinux-release";
    elif [ -f "/etc/lsb-release" ];           then echo "/etc/lsb-release";
    elif [ -f "/etc/alpine-release" ];        then echo "/etc/alpine-release";
    elif [ -f "/etc/arch-release" ];          then echo "/etc/arch-release";
    elif [ -f "/etc/os-release" ];            then echo "/etc/os-release";
    else
        duplib::error "Could not determine the release file";
        return 1;
    fi
}

function duplib::get_dup_linux_distribution_specific_folder() {
    if [ -f "/etc/lsb-release" ]; then
        echo "ubuntu";
    else
        basename `duplib::get_linux_distribution_release_file` | sed 's/release//' | sed 's/[-_]//'| tr '[:upper:]' '[:lower:]';
    fi
}

function duplib::copy_linux_distribution_specific_file() {
    if [ $# -lt 1 ]; then duplib::fatal_error "Missing argument 1 (directory)"; fi
    if [ $# -lt 2 ]; then duplib::fatal_error "Missing argument 2 (file_name)"; fi
    if [ $# -lt 3 ]; then duplib::fatal_error "Missing argument 3 (destination)"; fi

    local sub_directory="$1";
    local file_name="$2";
    local destination="$3";
    local copied_file="false";

    local relative_path="vagrant/files/$sub_directory";

    # Look for a custom file
    copied_file=$(duplib::_copy_linux_distribution_specific_file_custom "$relative_path" "$file_name" "$destination");
    if [[ "$copied_file" == "true" ]]; then
        return 0;
    fi

    # Look for a default file
    copied_file=$(duplib::_copy_linux_distribution_specific_file_dup "$relative_path" "$file_name" "$destination");
    if [[ "$copied_file" == "true" ]]; then
        return 0;
    fi
    duplib::fatal_error "No distribution specific or general file $file_name found $(duplib::get_dup_linux_distribution_specific_folder)";
}

function duplib::_copy_linux_distribution_specific_file_custom() {
    if [ $# -lt 1 ]; then duplib::fatal_error "Missing argument 1 (relative_path)"; fi;
    if [ $# -lt 2 ]; then duplib::fatal_error "Missing argument 2 (file_name)"; fi
    if [ $# -lt 3 ]; then duplib::fatal_error "Missing argument 3 (destination)"; fi

    local absolute_file_path="/vagrant/$DUP_CUSTOM_PROVISION_FOLDER/$1";
    local file_name="$2";
    local destination="$3";

    ## Check if there is a special file for the linux distribution
    local file_path_linux_distribution_specific_path="$absolute_file_path/$(duplib::get_dup_linux_distribution_specific_folder)/$file_name";
    if [[ -e "$file_path_linux_distribution_specific_path" ]]; then
        cp "$file_path_linux_distribution_specific_path" "$destination";
    elif [[ -e "$absolute_file_path/general/$file_name" ]]; then # Copy the default file
        cp "$absolute_file_path/general/$file_name" "$destination";
    else
        echo "false";
    fi
    echo "true";
}

function duplib::_copy_linux_distribution_specific_file_dup() {
    if [ $# -lt 1 ]; then duplib::fatal_error "Missing argument 1 (relative_path)"; fi;
    if [ $# -lt 2 ]; then duplib::fatal_error "Missing argument 2 (file_name)"; fi
    if [ $# -lt 3 ]; then duplib::fatal_error "Missing argument 3 (destination)"; fi

    local absolute_file_path="/vagrant/$DUP_BASE/$1";
    local file_name="$2";
    local destination="$3";

    ## Check if there is a special file for the linux distribution
    local file_path_linux_distribution_specific_path="$absolute_file_path/$(duplib::get_dup_linux_distribution_specific_folder)/$file_name";
    if [[ -e "$file_path_linux_distribution_specific_path" ]]; then
        cp "$file_path_linux_distribution_specific_path" "$destination";
    elif [[ -e "$absolute_file_path/general/$file_name" ]]; then # Copy the default file
        cp "$absolute_file_path/general/$file_name" "$destination";
    else
        echo "false";
    fi
    echo "true";
}
