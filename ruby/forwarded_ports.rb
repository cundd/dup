def configureForwardedPort(config, guest, host)
    config.vm.network "forwarded_port", guest: guest, host: host
end

def configureForwardedPorts(config, forwardedPorts)
    forwardedPorts.each do |guest, host|
        configureForwardedPort(config, guest, host)
    end
end

def configureAllForwardedPorts(config)
    forwardedPorts = getConfig()['vagrant']['vm']['forwarded_ports']
    if forwardedPorts
        configureForwardedPorts(config, forwardedPorts)
    end
end
