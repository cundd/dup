# --------------------------------------------------------
# Webserver/Apache methods
# --------------------------------------------------------

# Returns the vhost document root for the host VM
function dupcli::_webserver::get_host_vhost_document_root() {
    if [ ! -z ${DUP_VHOST_DOCUMENT_ROOT+x} ]; then
        echo $DUP_VHOST_DOCUMENT_ROOT;
    else
        echo "$(dirname "$0")/../httpdocs";
    fi
}

# Returns the vhost document root for the guest VM
function dupcli::_webserver::get_guest_vhost_document_root() {
    if [ ! -z ${DUP_VHOST_DOCUMENT_ROOT+x} ]; then
        echo $DUP_VHOST_DOCUMENT_ROOT;
    else
        duplib::get_vhost_document_root;
    fi
}

# Returns the vhost document root
function dupcli::_webserver::get_vhost_document_root() {
    if [[ $(dupcli::is_guest) == "yes" ]]; then
        dupcli::_webserver::get_guest_vhost_document_root;
    else
        dupcli::_webserver::get_host_vhost_document_root;
    fi
}
