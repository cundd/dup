#!/usr/bin/env bash
#
# duplib = a bash function library

DUP_LIB_PATH="${DUP_LIB_PATH:-$0}";
if [ ! -e "$DUP_LIB_PATH" ]; then
    >&2 echo "Defined duplib path '$DUP_LIB_PATH' not found";
    exit 1;
fi
DUP_LIB_INCLUDES_PATH="${DUP_LIB_INCLUDES_PATH:-$(dirname "$DUP_LIB_PATH")/includes}";

source "$DUP_LIB_INCLUDES_PATH/utils.sh";
source "$DUP_LIB_INCLUDES_PATH/os.sh";
source "$DUP_LIB_INCLUDES_PATH/service.sh";
source "$DUP_LIB_INCLUDES_PATH/package.sh";
source "$DUP_LIB_INCLUDES_PATH/webserver.sh";
