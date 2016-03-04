require 'yaml'
require 'singleton'

module Dup
    module Core
        class Config
            include Singleton

            def initialize
                @logger = Dup::Log::Logger.new()

                dir = File.dirname(File.expand_path(__FILE__))
                @basePath = "#{dir}/../../.."
                @projectBasePath = "#{@basePath}/.."
                @configuration = {}

                loadCoreConfiguration()
                loadModuleConfiguration()
                loadCustomConfiguration()
            end

            def get
                @configuration
            end

            def getScriptEnvironment
                env = get()['scripts']['ENV']

                addPhpConfigurationToEnvironment(env)

                env['DUP_LIB_PATH'] = "/vagrant/dup/shell/lib/duplib.sh"

                return env
            end

            def basePath
                @basePath
            end
            def projectBasePath
                @projectBasePath
            end

            def coreConfiguration
                @coreConfiguration
            end

            private

            def loadCoreConfiguration
                @coreConfiguration = YAML.load_file("#{@basePath}/default-config.yaml")

                if File.exist?("#{@basePath}/config.yaml")
                    oldConfig = YAML.load_file("#{@basePath}/config.yaml")
                    @coreConfiguration.deep_merge!(oldConfig)
                end

                @configuration = @coreConfiguration
            end

            def loadCustomConfiguration
                if TEST && File.exist?("#{Dir.getwd}/test-config.yaml")
                    @customConfiguration = YAML.load_file("#{Dir.getwd}/test-config.yaml")
                elsif File.exist?("#{@projectBasePath}/config.yaml")
                    @customConfiguration = YAML.load_file("#{@projectBasePath}/config.yaml")
                elsif File.exist?("#{@projectBasePath}/custom-config.yaml")
                    @customConfiguration = YAML.load_file("#{@projectBasePath}/custom-config.yaml")
                elsif File.exist?("#{@basePath}/custom-config.yaml")
                    @customConfiguration = YAML.load_file("#{@basePath}/custom-config.yaml")
                else
                    @customConfiguration = {}
                end

                @configuration.deep_merge!(@customConfiguration)
                # puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
                # #puts @coreConfiguration
                # puts @configuration
                # puts @configuration['modules']
                # #puts @moduleConfiguration, @configuration
                # puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
            end

            def loadModuleConfiguration
                @moduleConfiguration = {}
                moduleRegistry = Dup::Modules::Registry.new(self)
                registeredModules = moduleRegistry.registeredModules
                registeredModules.each do |moduleName|
                    moduleDirectoryPath = moduleRegistry.getModuleDirectory(moduleName)
                    configurationFilePath = "#{moduleDirectoryPath}/config/config.yaml"

                    if File.exist?(configurationFilePath)
                        loadedConfiguration = YAML.load_file(configurationFilePath)
                        @moduleConfiguration[moduleName] = loadedConfiguration[moduleName]
                    else
                        @logger.debug "No config file #{configurationFilePath}"
                        @moduleConfiguration[moduleName] = {}
                    end
                end

                @configuration['modules'].deep_merge!(@moduleConfiguration)
                # puts "=========================================================================================================================================="
                # puts @coreConfiguration
                # puts @configuration
                # puts @moduleConfiguration, @configuration
                # puts "=========================================================================================================================================="
            end
        end
    end
end
