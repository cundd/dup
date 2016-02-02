# --------------------------------------------------------
# Cache methods
# --------------------------------------------------------
: ${DUP_CLI_CACHE_LIFETIME="300"}
: ${DUP_CACHE_PATH="$HOME/.dup_cache"}

function dupcli::_cache::cache_age_test() {
    if [ "$#" -ne 1 ]; then
        duplib::fatal_error "Missing argument 1 (cache_file)";
    fi
    local cache_file="$1";

    local cache_file_time=0;
    if stat -c "%Y" $cache_file &>/dev/null; then
        cache_file_time=$(stat -c "%Y" $cache_file 2>/dev/null);
    elif stat -f "%a" $cache_file &>/dev/null; then
        cache_file_time=$(stat -f "%a" $cache_file 2>/dev/null);
    fi

    let cache_age=$(date "+%s")-cache_file_time;

    if [[ $cache_age -gt "$DUP_CLI_CACHE_LIFETIME" ]]; then
        echo "false";
    else
        echo "true";
    fi
}

function dupcli::_cache::_get_cache_file_path() {
    if [ "$#" -lt 1 ]; then
        duplib::fatal_error "Missing argument 1 (cache_key)";
    fi
    local key="$1";
    local key_clean=$(echo $key | sed 's/[^a-zA-Z_-]//g');
    echo "$DUP_CACHE_PATH/$key_clean";
}

function dupcli::_cache::check_cache() {
    if [ "$#" -lt 1 ]; then
        duplib::fatal_error "Missing argument 1 (cache_key)";
    fi

    if [ ! -e "$DUP_CACHE_PATH" ]; then
        mkdir "$DUP_CACHE_PATH";
    fi

    local cache_file="$(dupcli::_cache::_get_cache_file_path $1)";

    # Check if the cache file exists and that it isn't too old
    if [[ ! -e "$cache_file" ]]; then
        echo "false";
    elif [ "$(dupcli::_cache::cache_age_test "$cache_file")" == "true" ]; then
        echo "true";
    else
        echo "false";
    fi
}

function dupcli::_cache::check_cache_or_set() {
    if [ "$#" -lt 1 ]; then
        duplib::fatal_error "Missing argument 1 (cache_key)";
    elif [ "$#" -lt 2 ]; then
        duplib::fatal_error "Missing argument 1 (callable)";
    fi

    local key="$1";
    local callable="$2";
    local cache_file="$(dupcli::_cache::_get_cache_file_path $key)";

    if [[ "$(dupcli::_cache::check_cache $key)" != "true" ]]; then
        $callable > "$cache_file";
    fi
}

function dupcli::_cache::check_cache_or_set_and_print() {
    if [ "$#" -lt 1 ]; then
        duplib::fatal_error "Missing argument 1 (cache_key)";
    elif [ "$#" -lt 2 ]; then
        duplib::fatal_error "Missing argument 1 (callable)";
    fi

    dupcli::_cache::check_cache_or_set "$1" "$2";

    cat "$(dupcli::_cache::_get_cache_file_path $1)";
}
