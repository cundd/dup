require 'yaml'

def getConfig
    dir = File.dirname(File.expand_path(__FILE__))
    defaultConfig = YAML.load_file("#{dir}/../default-config.yaml")

    if File.exist?("#{dir}/../config.yaml")
        oldConfig = YAML.load_file("#{dir}/../config.yaml")
        defaultConfig.deep_merge!(oldConfig)
    end

    if TEST && File.exist?("#{Dir.getwd}/test-config.yaml")
        customConfig = YAML.load_file("#{Dir.getwd}/test-config.yaml")
    elsif File.exist?("#{dir}/../../config.yaml")
        customConfig = YAML.load_file("#{dir}/../../config.yaml")
    elsif File.exist?("#{dir}/../../custom-config.yaml")
        customConfig = YAML.load_file("#{dir}/../../custom-config.yaml")
    elsif File.exist?("#{dir}/../custom-config.yaml")
        customConfig = YAML.load_file("#{dir}/../custom-config.yaml")
    else
        customConfig = {}
    end

    return defaultConfig.deep_merge(customConfig)
end

def getScriptEnvironment
    env = getConfig()['scripts']['ENV']

    addPhpConfigurationToEnvironment(env)

    env['DUP_LIB_PATH'] = "/vagrant/dup/shell/lib/duplib.sh"

    return env
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
