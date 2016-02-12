#!/bin/bash
#
# Detect the running OS and it's version
set -o nounset
set -o errexit

# Print the name of the OS
function dupcli::os::detect() {
    duplib::detect_os;
}

# Print the OS version
function dupcli::os::version() {
    duplib::detect_os_version;
}
