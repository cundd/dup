require 'yaml'

def getConfig
    configurationInstance = Dup::Core::Config.instance
    configurationInstance.get()
end

def getScriptEnvironment
    configurationInstance = Dup::Core::Config.instance
    configurationInstance.getScriptEnvironment()
end

# @deprecated create a module instead
def phpIni
    phpCustomIni = []
    if getConfig()['php']['ini']
        getConfig()['php']['ini'].each do |name, value|
            phpCustomIni.push("#{name}=#{value}")
        end
    end
    return phpCustomIni
end

# @deprecated create a module instead
def addPhpFeaturesToEnvironment(env)
    phpFeatures = getConfig()['php']['features']
    if phpFeatures
        phpFeatures.each do |key, value|
            env['PHP_FEATURE_' + key.upcase] = value
        end
    end
end

# @deprecated create a module instead
def addPhpConfigurationToEnvironment(env)
    if getConfig()['php']
        env['PHP_CUSTOM_INI'] = phpIni.join(";")
        addPhpFeaturesToEnvironment(env)
    end
end
