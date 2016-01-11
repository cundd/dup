def configureAutomaticHostname(config, path)
    hostname = getConfig()['vagrant']['vm']['hostname']
    if hostname == 'automatic'
        config.vm.hostname = File.basename(File.expand_path(path))
    elsif hostname
        config.vm.hostname = hostname
    end
end
