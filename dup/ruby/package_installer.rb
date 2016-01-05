def configureInstallPackages(config, packages)
    rubyDir = File.dirname(File.expand_path(__FILE__))
    installerPath = "#{rubyDir}/../scripts/special/package-installer.sh";

    allPackages = packages.join(" ")
    config.vm.provision "install-packages", type: "shell", privileged: true, path: installerPath, args: [allPackages]
end
