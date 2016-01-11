def configureAutomaticHostname(config, path)
    config.vm.hostname = File.basename(File.expand_path(path))
end
