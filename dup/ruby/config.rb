require 'yaml'

def getConfig
    dir = File.dirname(File.expand_path(__FILE__))
    return YAML.load_file("#{dir}/../config.yaml")
end

def getScriptEnvironment
    return getConfig()['scripts']['ENV']
end
