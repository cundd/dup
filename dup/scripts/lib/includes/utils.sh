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

function duplib::error() {
    >&2 echo "$@";
}

function error() {
    duplib::error $@;
}
