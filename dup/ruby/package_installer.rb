def configureInstallPackage(config, package)
    config.vm.provision "shell", privileged: true, inline: "pacman -S --noconfirm --needed " + package
end
def configureInstallPackages(config, packages)
    allPackages = packages.join(" ")
    config.vm.provision "shell", privileged: true, inline: "pacman -S --noconfirm --needed #{allPackages}"
end
