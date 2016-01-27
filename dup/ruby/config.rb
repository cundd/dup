require 'yaml'

def getConfig
    dir = File.dirname(File.expand_path(__FILE__))
    defaultConfig = YAML.load_file("#{dir}/../config.yaml")
    if File.exist?("#{dir}/../../custom-config.yaml")
        customConfig = YAML.load_file("#{dir}/../../custom-config.yaml")
    elsif File.exist?("#{dir}/../custom-config.yaml")
        customConfig = YAML.load_file("#{dir}/../custom-config.yaml")
    else
        customConfig = {}
    end

    return defaultConfig.deep_merge(customConfig)
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
