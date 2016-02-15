require 'uri'

def configureAutomaticHostname(config, path)
    hostname = getConfig()['vagrant']['vm']['hostname']
    if hostname == 'automatic'
        projectUrl = getConfig()['project']['dev']['url']
        if projectUrl
            config.vm.hostname = projectUrl
        else
            folderName = File.basename(File.expand_path(path))
            if folderName.scan(URI.regexp)
                config.vm.hostname = folderName
            end
        end
    elsif hostname
        config.vm.hostname = hostname
    end
end
