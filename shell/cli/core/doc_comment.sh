# --------------------------------------------------------
# Doc Comment methods
# --------------------------------------------------------
function dupcli::_doc_comment::doc_comment_for_command() {
    if [ "$#" -eq 0 ]; then
        duplib::fatal_error "Missing argument 1 (command)";
    fi

    readonly command="$1";
    local include_arguments="false";
    if [ "$#" -eq 2 ]; then
        include_arguments="$2";
    fi
    dupcli::_cache::check_cache_or_set_and_print "command-$command-$include_arguments" \
        "dupcli::_doc_comment::build_doc_comment_for_command $command $include_arguments";
}

function dupcli::_doc_comment::build_doc_comment_for_command() {
    if [ "$#" -eq 0 ]; then
        duplib::fatal_error "Missing argument 1 (command)";
    fi
    readonly command_name="$1";

    local include_arguments="false";
    if [ "$#" -eq 2 ]; then
        include_arguments="$2";
    fi
    local function_definition="function dupcli::$command_name()";

    local file="";
    if [[ "$command_name" = *::* ]]; then
        file=$(echo "$command_name" | awk -F:: '{print $1}');
        file="$(dupcli::_plugins::directory)/$file.sh";
    else
        file="$0";
    fi

    ## Find the function
    local doc_comment="";
    local argument_comments="";
    readonly argument_indent='  ';
    local line_stripped="";

    ## Loop through the function header
    while read -r line ; do
        if echo "$line" | grep -q "^# \w" ; then
            # Collect the line if it is a comment
            line_stripped=$(echo "$line" | sed "s/^\(# \)//" | sed "s/ $//");
            doc_comment="$doc_comment$line_stripped ";
        elif echo "$line" | grep -q "^# \$\w" ; then
            # Collect the lines of arguments
            line_stripped=$(echo "$line" | sed "s/^\(# \)//" | sed "s/ $//");
            argument_comments="$argument_comments
$argument_indent$line_stripped ";
        elif [[ "$line" == "$function_definition"* ]] ; then
            # If the function declaration is reached break
            break 2;
        else
            # Clear the collected lines if something new started here
            doc_comment='';
            argument_comments='';
        fi
    done < <(grep -B 5 -F "$function_definition" "$file"); # Get the function header

    if [[ "$doc_comment" != "" ]]; then
        echo "$doc_comment";
    fi
    if [[ "$include_arguments" == "true" ]] && [[ "$argument_comments" != "" ]]; then
        echo "$argument_comments";
    fi
}

function dupcli::_doc_comment::list_plugin_doc_comments() {
    readonly line_start='declare -f dupcli::';
    local line_start_search="$line_start";
    if [[ ! -z ${1+x} ]]; then
        line_start_search="$line_start_search$1";
    fi

    for command in $(dupcli::_list_commands); do
        dupcli::_doc_comment::doc_comment_for_command $command
    done
}
