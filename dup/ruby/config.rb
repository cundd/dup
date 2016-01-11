require 'yaml'

def getConfig
    dir = File.dirname(File.expand_path(__FILE__))
    return YAML.load_file("#{dir}/../config.yaml")
end

def phpIni
    phpCustomIni = []
    getConfig()['php']['ini'].each do |name, value|
        phpCustomIni.push("#{name}=#{value}")
    end
    return phpCustomIni
end

def addPhpFeaturesToEnvironment(env)
    phpFeatures = getConfig()['php']['features']

    phpFeatures.each do |key, value|
        env['PHP_FEATURE_' + key.upcase] = value
    end
end

def getScriptEnvironment
    env = getConfig()['scripts']['ENV']

    env['PHP_CUSTOM_INI'] = phpIni.join(" ")
    addPhpFeaturesToEnvironment(env)

    env['DUP_LIB_PATH'] = "/vagrant/dup/scripts/lib/duplib.sh"

    return env
end
