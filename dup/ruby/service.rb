def configureService(config, service)
    env = getScriptEnvironment()
    rubyDir = File.dirname(File.expand_path(__FILE__))
    serviceStarterPath = "#{rubyDir}/../scripts/special/service-starter.sh";

    config.vm.provision "service-#{service}", type: "shell", privileged: true, env: env, path: serviceStarterPath, args: [service], run: "always"
end

def configureServices(config, services)
    services.each do |service|
        configureService(config, service)
    end
end

def configureAllServices(config)
    services = getConfig()['services']
    if services
        configureServices(config, services)
    end
end
