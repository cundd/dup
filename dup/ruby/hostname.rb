def configureAutomaticHostname(config, path)
    puts "hostname #{File.basename(File.dirname(File.expand_path(path)))}"
    config.vm.hostname = File.basename(File.dirname(File.expand_path(path)))
end
