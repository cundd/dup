def configureInstallPackages(config, packages)
    rubyDir = File.dirname(File.expand_path(__FILE__))
    installerPath = "#{rubyDir}/../vagrant/scripts/special/package-installer.sh"
    env = getScriptEnvironment()

    allPackages = packages.join(" ")
    config.vm.provision "install-packages", type: "shell", privileged: true, path: installerPath, args: [allPackages], env: env
end
def configureInstallAllPackages(config)
    packages = getConfig()['packages']
    if packages
        configureInstallPackages(config, packages)
    end
end
