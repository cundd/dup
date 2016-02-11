def configureSyncedFolders(config)
    # Configure synced folders
    shareType = getConfig()['vagrant']['vm']['share_type']

    if TEST
        vagrantShareRoot = "../.."
        config.vm.synced_folder ".", "/vagrant", disabled: true

        if shareType && shareType != "default"
            config.vm.synced_folder vagrantShareRoot, "/vagrant/dup", type: shareType
        else
            config.vm.synced_folder vagrantShareRoot, "/vagrant/dup"
        end
    else
        vagrantShareRoot = "."
        if shareType && shareType != "default"
            config.vm.synced_folder vagrantShareRoot, "/vagrant", type: shareType
        else
            config.vm.synced_folder vagrantShareRoot, "/vagrant"
        end
    end

    if shareType && shareType != "default"
        config.vm.synced_folder "httpdocs", "/var/www/vhosts/dup.cundd.net/httpdocs", type: shareType
    else
        config.vm.synced_folder "httpdocs", "/var/www/vhosts/dup.cundd.net/httpdocs"
    end
end
