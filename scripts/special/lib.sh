#!/bin/bash
set -o nounset
set -o errexit

DUP_LIB_PATH="${DUP_LIB_PATH:-$(dirname "$0")/../lib/duplib.sh}";
source "$DUP_LIB_PATH";
