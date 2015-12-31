def configureService(config, service)
    config.vm.provision "service-#{service}", type: "shell", privileged: true, inline: "systemctl start #{service}", run: "always"
end

def configureServices(config, services)
    config.vm.provision "shell", privileged: true, inline: "systemctl daemon-reload", run: "always"

    services.each do |service|
        configureService(config, service)
    end
end
