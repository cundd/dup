# --------------------------------------------------------
# Help methods
# --------------------------------------------------------
function dupcli::_help::print_help() {
    if [ $# -gt 0 ] && [[ "$1" != "" ]]; then
        dupcli::_help::_search_and_print "$@";
    else
        dupcli::_help::_print_full_help "$@";
    fi
}

function dupcli::_help::print_suggestion() {
    if [ $# -eq 0 ] || [[ "$1" == "" ]]; then
        duplib::error "Missing argument 1 ($1 command_search)";
        return 1;
    fi

    local filter_commands="$1";
    local matching_commands=$(dupcli::_help::search_commands $filter_commands);

    if [ "$matching_commands" != "" ]; then
        echo "Did you mean one of these?";
    else
        echo "No matching commands found";
    fi

    for command in $matching_commands; do
        dupcli::_help::_print_command_help_line $command;
    done
}

function dupcli::_help::print_usage() {
    local second_part='';
    if [ $# -eq 0 ]; then
        second_part='<command>';
    else
        second_part="$1 <subcommand>";
    fi

    echo "Usage $0 $second_part [<args>]
";
}

function dupcli::_help::search_commands() {
    local all_commands=$(dupcli::_list_commands);
    if [ $# -eq 0 ] || [[ "$1" == "" ]] || [[ "$1" == "*" ]]; then
        echo $all_commands;
        return 0;
    fi

    local search="$1";
    local mode="start";
    local pattern='';
    if [ $# -gt 1 ]; then
        mode="$2";
    fi

    case $mode in
        "start") pattern="^$search" ;;
        "nice") pattern="$search" ;;
        "strict") pattern="^$search$" ;;
        *) pattern="^$search$" ;;
    esac

    echo "$all_commands" | grep "$pattern";
}

# --------------------------------------------------------
# Private methods
# --------------------------------------------------------
function dupcli::_help::_print_full_help() {
    dupcli::_help::print_usage;

    echo "Commands:";
    for command in $(dupcli::_help::search_commands); do
        dupcli::_help::_print_command_help_line $command;
    done
}

function dupcli::_help::_search_and_print() {
    if [ $# -eq 0 ] || [[ "$1" == "" ]]; then
        duplib::error "Missing argument 1 (command_search)";
        return 1;
    fi
    readonly filter_commands="$1";

    readonly matching_commands=$(dupcli::_help::search_commands $filter_commands);

    if [ "$matching_commands" == "" ]; then
        # No match found
        echo "No matching commands found for '$filter_commands'";
        return 1;
    fi

    readonly matching_commands_count=$(echo $matching_commands | wc -w);

    if [[ "$matching_commands_count" -eq "1" ]]; then
        # One matching command
        dupcli::_help::_print_single_command_help "$filter_commands";
    elif [ "$matching_commands" != "" ]; then
        # Print suggestions
        echo "Did you mean one of these?";
        for command in $matching_commands; do
            dupcli::_help::_print_command_help_line "$command";
        done
    else
        # No match found
        echo "No matching commands found";
        return 1;
    fi
}

function dupcli::_help::_print_single_command_help() {
    local command="$1";

    dupcli::_help::print_usage "$command";
    dupcli::_doc_comment::doc_comment_for_command $command true;
    # local line=$(printf '%0.1s' " "{1..28});
    # printf "    %s %s $help\n" $command "${line:${#command}}"
}

function dupcli::_help::_print_command_help_line() {
    local command="$1";
    local help=$(dupcli::_doc_comment::doc_comment_for_command $command);

    local line=$(printf '%0.1s' " "{1..28});
    printf "    %s %s $help\n" $command "${line:${#command}}"
}
