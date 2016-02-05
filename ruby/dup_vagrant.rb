def configureVagrant(config)
    dir = File.dirname(File.expand_path(__FILE__))
    dupDirectoryName = 'dup'
    dupScriptsBase = "#{dir}/../vagrant/scripts"
    dupUserScriptsBase = "#{dir}/../../provision/scripts"
    dupFilesBase = "#{dir}/../vagrant/files"
    vagrantBase = File.expand_path("#{dir}/../../")

    # Vagrant box to use
    # Default dup box is "dupal" from
    # https://github.com/cundd/vagrant-boxes/releases/download/0.1.0/alpine-3.3.0-x86_64.box
    config.vm.box = getConfig()['vagrant']['vm']['box']

    configureAllForwardedPorts(config)

    if getConfig()['vagrant']['vm']['ip']
        config.vm.network "private_network", ip: getConfig()['vagrant']['vm']['ip']
    else
        abort("Please specify an IP for the VM in your config.yaml")
    end

    # Configure synced folders
    shareType = getConfig()['vagrant']['vm']['share_type']
    if shareType && shareType != "default"
        config.vm.synced_folder "httpdocs", "/var/www/vhosts/dup.cundd.net/httpdocs", type: shareType
        config.vm.synced_folder ".", "/vagrant", type: shareType
    else
        config.vm.synced_folder "httpdocs", "/var/www/vhosts/dup.cundd.net/httpdocs"
        config.vm.synced_folder ".", "/vagrant"
    end

    # Set the hostname
    configureAutomaticHostname(config, vagrantBase)

    # Configure networking
    configureRunScriptsFromDirectory(config, dupScriptsBase + '/special/networking-setup.sh', privileged: true)

    # Upgrade the system
    configureRunScriptsFromDirectory(config, dupScriptsBase + '/special/system-update.sh', privileged: true)

    # Install packages
    configureInstallAllPackages(config)

    # Run scripts
    configureRunScriptsFromDirectory(config, dupScriptsBase + '/privileged_once/*.sh', privileged: true)
    configureRunScriptsFromDirectory(config, dupUserScriptsBase + '/privileged_once/*.sh', privileged: true)
    configureRunScriptsFromDirectory(config, dupScriptsBase + '/privileged_always/*.sh', privileged: true, always: true)
    configureRunScriptsFromDirectory(config, dupUserScriptsBase + '/privileged_always/*.sh', privileged: true, always: true)
    configureRunScriptsFromDirectory(config, dupScriptsBase + '/unprivileged_once/*.sh')
    configureRunScriptsFromDirectory(config, dupUserScriptsBase + '/unprivileged_once/*.sh')
    configureRunScriptsFromDirectory(config, dupScriptsBase + '/unprivileged_always/*.sh', always: true)
    configureRunScriptsFromDirectory(config, dupUserScriptsBase + '/unprivileged_always/*.sh', always: true)

    # Start services
    configureAllServices(config)
end
