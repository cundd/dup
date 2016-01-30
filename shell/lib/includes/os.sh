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
        error "Could not determine the release file";
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
    if [ -z ${1+x} ]; then
        error "Missing argument directory";
        return 1;
    else
        local subDirectory="$1";
    fi
    if [ -z ${2+x} ]; then
        error "Missing argument fileName";
        return 1;
    else
        local fileName="$2";
    fi
    if [ -z ${3+x} ]; then
        error "Missing argument destination";
        return 1;
    else
        local destination="$3";
    fi

    local dupFilesPath="/vagrant/$DUP_BASE/vagrant/files/$subDirectory";

    ## Check if there is a special file for the linux distribution
    if [[ -e "$dupFilesPath/$(duplib::get_dup_linux_distribution_specific_folder)/$fileName" ]]; then
        cp "$dupFilesPath/$(duplib::get_dup_linux_distribution_specific_folder)/$fileName" "$destination";
    elif [[ -e "$dupFilesPath/general/$fileName" ]]; then # Copy the default file
        cp "$dupFilesPath/general/$fileName" "$destination";
    else
        error "No distribution specific or general file $fileName found $(duplib::get_dup_linux_distribution_specific_folder)";
        return 1;
    fi
}
