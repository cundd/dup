# --------------------------------------------------------
# File methods
# --------------------------------------------------------
function duplib::add_string_to_file_if_not_found() {
    if [[ -z ${1+x} ]]; then echo "Missing argument 1 (pattern)"; return 1; fi;
    if [[ -z ${2+x} ]]; then echo "Missing argument 2 (file)"; return 1; fi;

    local pattern=$1;
    local file=$2;

    if [[ -z ${3+x} ]]; then
        local string=$pattern;
    else
        local string=$3;
    fi

    grep -q "$pattern" "$file" || echo "$string" >> "$file";
}


# --------------------------------------------------------
# Host/guest detection
# --------------------------------------------------------
# Try to find out if the current machine is the guest
function duplib::is_guest() {
    local is_guest_value=10;

    if hash VBoxManage 2>/dev/null; then
        let is_guest_value--;
    fi

    if [[ -e "/vagrant" ]]; then
        let is_guest_value++;
    fi

    if [[ -e "/proc/scsi/scsi" ]] && grep -qF "VBOX HARDDISK" /proc/scsi/scsi; then
        let is_guest_value++;
    fi

    if [ -z ${DUP_VHOST_DOCUMENT_ROOT+x} ]; then
        let is_guest_value++;
    fi

    if [ $is_guest_value -gt 10 ]; then
        echo "yes";
    else
        echo "no";
    fi
}

# Try to find out if the current machine is the host
function duplib::is_host() {
    if [[ $(dupcli::is_guest) == "no" ]]; then
        echo "yes";
    else
        echo "no";
    fi
}

# --------------------------------------------------------
# Helpers
# --------------------------------------------------------
#
function duplib::dup_checksum() {
    if [ -z ${DUP_CLI_PATH+x} ]; then
        duplib::fatal_error "Variable DUP_CLI_PATH not set";
    fi
    local md5_command;
    if hash "md5sum" 2>/dev/null; then
        md5_command="md5sum";
    elif hash "md5" 2>/dev/null; then
        md5_command="md5";
    else
        duplib::fatal_error "No md5 tool found";
    fi

    find "$DUP_CLI_PATH" -type f -exec $md5_command {} + | awk '{print $1}' | sort | $md5_command;
}

# Returns if the given command is available
function duplib::command_exists() {
    if [[ -z ${1+x} ]]; then duplib::error "Missing argument 1 (command name)"; return 1; fi;
    if hash "$1" 2>/dev/null; then
        return 0;
    else
        return 1;
    fi
}

# Display a fatal error and exit if the given command is not available
function duplib::check_required_command() {
    if [[ -z ${1+x} ]]; then duplib::error "Missing argument 1 (command name)"; return 1; fi;
    if hash "$1" 2>/dev/null; then
        return 0;
    else
        duplib::fatal_error "Command $1 not found";
    fi
}

function duplib::get_option_is_set() {
    if [[ -z ${1+x} ]]; then duplib::error "Missing argument 1 (option)"; return 1; fi;

    local option="$1";
    shift;

    while test $# -gt 0; do
        if [[ "$1" == "$option" ]]; then
            echo "true";
            return 0;
        fi
        shift
    done

    echo "false";
}

function duplib::is_integer() {
    if [[ -z ${1+x} ]]; then duplib::error "Missing argument 1 (input)"; return 1; fi;

    local re='^[0-9]+$';
    if [[ $1 =~ $re ]] ; then
        echo "true";
    else
        echo "false";
    fi
}

function duplib::rsync() {
    if [[ -z ${1+x} ]]; then duplib::error "Missing argument 1 (user@server)"; return 1; fi;
    if [[ -z ${2+x} ]]; then duplib::error "Missing argument 2 (remote_path)"; return 1; fi;
    if [[ -z ${3+x} ]]; then duplib::error "Missing argument 3 (local_path)"; return 1; fi;
    if [[ -z ${4+x} ]]; then duplib::error "Missing argument 4 (excludes)"; return 1; fi;

    local user_and_server="$1";
    local remote_path="$2";
    local local_path="$3";
    local excludes="$4";

    shift 4;

    local ssh_options="ssh";
    if [[ ! -z ${1+x} ]] && [[ "$(duplib::is_integer $1)" == "true" ]]; then
        ssh_options="ssh -p $1";
        shift;
    fi;

    local dry="";
    if [[ $(duplib::get_option_is_set "-n" $@) == "true" ]]; then
        dry="-n";
    fi

    local progress="";
    if [[ $(duplib::get_option_is_set "--progress" $@) == "true" ]]; then
        progress="--progress";
    fi

    if [[ $(duplib::get_option_is_set "--not-stop-on-error" $@) == "true" ]]; then
        set +e;
    fi

    if [[ "$dry" == "-n" ]]; then
        echo "rsync -zar $progress $dry $excludes -e '$ssh_options' $user_and_server:$remote_path $local_path";
    fi
    eval "rsync -zar $progress $dry $excludes -e '$ssh_options' $user_and_server:$remote_path $local_path";
}

function duplib::_tput() {
    if hash tput 2>/dev/null; then
        >&2 tput $@;
    fi
}

function duplib::error() {
    duplib::_tput setaf 1;
    >&2 echo "$@";
    duplib::_tput sgr0;
}

function error() {
    duplib::error $@;
}

function duplib::fatal_error() {
    duplib::error "$@";
    exit;
}
