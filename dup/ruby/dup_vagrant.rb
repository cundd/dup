def configureVagrant(config)
    dir = File.dirname(File.expand_path(__FILE__))
    dupDirectoryName = 'dup'
    dupScriptsBase = "#{dir}/../scripts"
    dupFilesBase = "#{dir}/../files"
    vagrantBase = File.expand_path("#{dir}/../../")

    # Use the vagrant box "dupal" from
    # https://github.com/cundd/vagrant-boxes/releases/download/0.1.0/alpine-3.3.0-x86_64.box
    config.vm.box = "dupal"

    config.vm.network "forwarded_port", guest: 80, host: 8080
    config.vm.network "private_network", ip: getConfig()['vagrant']['vm']['ip']

    # Configure synced folders
    config.vm.synced_folder "httpdocs", "/var/www/vhosts/dup.cundd.net/httpdocs", type: "nfs"
    config.vm.synced_folder ".", "/vagrant", type: "nfs"

    # Set the hostname
    configureAutomaticHostname(config, vagrantBase)

    # Configure networking
    configureRunScriptsFromDirectory(config, dupScriptsBase + '/special/networking-setup.sh', privileged: true)

    # Upgrade the system
    configureRunScriptsFromDirectory(config, dupScriptsBase + '/special/system-update.sh', privileged: true)

    # Install packages
    configureInstallPackages(config, getConfig()['packages'])

    # Run scripts
    configureRunScriptsFromDirectory(config, dupScriptsBase + '/privileged_once/*.sh', privileged: true)
    configureRunScriptsFromDirectory(config, dupScriptsBase + '/privileged_always/*.sh', privileged: true, always: true)
    configureRunScriptsFromDirectory(config, dupScriptsBase + '/unprivileged_once/*.sh')
    configureRunScriptsFromDirectory(config, dupScriptsBase + '/unprivileged_always/*.sh', always: true)

    # Start services
    configureServices(config, getConfig()['services'])
end
