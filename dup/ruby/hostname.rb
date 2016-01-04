def configureAutomaticHostname(config, path)
    config.vm.hostname = File.basename(File.dirname(File.expand_path(path)))
end
