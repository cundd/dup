# --------------------------------------------------------
# Doc Comment methods
# --------------------------------------------------------

function dupcli::_doc_comment::cache_dir() {
    echo "$DUP_CACHE_PATH/doc_comment";
}

function dupcli::_doc_comment::cache_age_test() {
    if [ "$#" -ne 1 ]; then
        duplib::fatal_error "Missing argument 1 (cache_file)";
    fi
    local cache_file="$1";

    if stat --version &>/dev/null; then
        let cache_age=$(date "+%s")-$(stat -c "%Y" $cache_file );
    else
        let cache_age=$(date "+%s")-$(stat -f "%a" $cache_file );
    fi

    if [[ $cache_age -gt 300 ]]; then
        echo "false";
    else
        echo "true";
    fi
}

function dupcli::_doc_comment::doc_comment_for_command() {
    if [ "$#" -ne 1 ]; then
        duplib::fatal_error "Missing argument 1 (command)";
    fi

    local command="$1";
    local command_clean=$(echo $command | sed 's/:/-/g');
    local cache_directory="$(dupcli::_doc_comment::cache_dir)";

    if [ ! -e "$cache_directory" ]; then
        mkdir "$cache_directory";
    fi

    local cache_file="$cache_directory/command_$command_clean";

    # Check if the cache file exists and that it isn't too old
    if [[ -e "$cache_file" ]]; then
        if [ "$(dupcli::_doc_comment::cache_age_test "$cache_file")" != "true" ]; then
            dupcli::_doc_comment::build_doc_comment_for_command "$command" > "$cache_file";
        fi
    else
        dupcli::_doc_comment::build_doc_comment_for_command "$command" > "$cache_file";
    fi

    cat "$cache_file";
}

function dupcli::_doc_comment::build_doc_comment_for_command() {
    if [ "$#" -ne 1 ]; then
        duplib::fatal_error "Missing argument 1 (command)";
    fi
    local command="$1";
    local function_definition="function dupcli::$command()";

    local file="";
    if [[ "$command" = *::* ]]; then
        file=$(echo "$command" | awk -F:: '{print $1}');
        file="$(dupcli::_plugins::directory)/$file.sh";
    else
        file="$0";
    fi

    ## Find the function
    local function_header=$(grep -B 5 -F "$function_definition" "$file");
    local doc_comment="";
    local line_stripped="";

    ## Loop through the function header
    echo "$function_header" | while read -r line ; do
        if echo "$line" | grep -q "^# \w" ; then
            # Collect the line if it is a comment
            line_stripped=$(echo "$line" | sed "s/^\(# \)//" | sed "s/ $//");
            doc_comment="$doc_comment$line_stripped ";
        elif [[ "$line" == "$function_definition"* ]] ; then
            # Print the collected lines if the current line is the function definition
            if [[ "$doc_comment" != "" ]]; then
                echo "$doc_comment";
            fi
            return 0;
        else
            # Clear the collected lines if something new started here
            doc_comment="";
        fi
    done
}

function dupcli::_doc_comment::list_plugin_doc_comments() {
    local line_start='declare -f dupcli::';
    local line_start_search="$line_start";
    if [[ ! -z ${1+x} ]]; then
        line_start_search="$line_start_search$1";
    fi

    for command in $(dupcli::_list_commands); do
        dupcli::_doc_comment::doc_comment_for_command $command
    done
}
