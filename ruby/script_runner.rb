def configureRunScript(config, path, privileged=false, always=false)
    env = getScriptEnvironment()
    name = File.basename(path, File.extname(path))
    name += '_' + File.basename(File.dirname(path)).sub('_', '-')

    if always
        config.vm.provision(name, type: "shell", privileged: privileged, path: path, env: env, run: "always")
    else
        config.vm.provision(name, type: "shell", privileged: privileged, path: path, env: env)
    end
end

def configureRunScriptsFromDirectory(config, path, privileged: false, always: false)
    Dir.glob(path) do |scriptFile|
        configureRunScript(config, scriptFile, privileged, always)
    end
end
