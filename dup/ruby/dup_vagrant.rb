def configureVagrant(config)
    dir = File.dirname(File.expand_path(__FILE__))
    vagrantName = 'dup'
    vagrantBase = dir + '/' + vagrantName
    vagrantScriptsBase = vagrantBase + '/scripts'
    vagrantFileBase = vagrantBase + '/files'

    # Use the vagrant box "dupal" from
    # https://github.com/cundd/vagrant-boxes/releases/download/0.1.0/alpine-3.3.0-x86_64.box
    config.vm.box = "dupal"

    config.vm.network "forwarded_port", guest: 80, host: 8080
    config.vm.network "private_network", ip: getConfig()['vagrant']['vm']['ip']

    config.vm.synced_folder "httpdocs", "/var/www/vhosts/dup.cundd.net/httpdocs", type: "nfs"
    config.vm.synced_folder ".", "/vagrant", type: "nfs"

    configureAutomaticHostname(config, __FILE__)

    # Upgrade the system
    configureRunScriptsFromDirectory(config, vagrantScriptsBase + '/special/system-update.sh', privileged: true)

    # Install packages
    configureInstallPackages(config, getConfig()['packages'])
    

    # Run scripts
    configureRunScriptsFromDirectory(config, vagrantScriptsBase + '/privileged_once/*.sh', privileged: true)
    configureRunScriptsFromDirectory(config, vagrantScriptsBase + '/privileged_always/*.sh', privileged: true, always: true)
    configureRunScriptsFromDirectory(config, vagrantScriptsBase + '/unprivileged_once/*.sh')
    configureRunScriptsFromDirectory(config, vagrantScriptsBase + '/unprivileged_always/*.sh', always: true)

    # Start services
    configureServices(config, getConfig()['services'])
end
