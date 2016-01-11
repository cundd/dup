#!/bin/bash
#
# duplib = a bash library

DUP_LIB_PATH="${DUP_LIB_PATH:-$0}";
DUP_LIB_INCLUDES_PATH="${DUP_LIB_INCLUDES_PATH:-$(dirname "$DUP_LIB_PATH")/includes}";

source "$DUP_LIB_INCLUDES_PATH/utils.sh";
source "$DUP_LIB_INCLUDES_PATH/os.sh";
source "$DUP_LIB_INCLUDES_PATH/service.sh";
source "$DUP_LIB_INCLUDES_PATH/package.sh";
source "$DUP_LIB_INCLUDES_PATH/apache.sh";
