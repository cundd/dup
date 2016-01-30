def configureSudoCopyFile(config, source, targetDirectory)
    sourceFileName = File.basename(source);
    inlineCommand = <<COMMAND
cp /vagrant/#{source} #{targetDirectory};
chmod o+r "#{targetDirectory}/#{sourceFileName}";
ls -hl #{targetDirectory}
COMMAND
    config.vm.provision "shell", privileged: true, inline: inlineCommand, run: "always"
end
