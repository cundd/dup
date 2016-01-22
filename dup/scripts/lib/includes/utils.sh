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
# Helpers
# --------------------------------------------------------
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
        tput $@;
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
