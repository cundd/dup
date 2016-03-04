module Dup
    module Modules
        class Loader
            def initialize()
                require "log4r"
                @logger = Log4r::Logger.new("vagrant::ui::interface")
                @moduleRegistry = Dup::Modules::Registry.new()
            end

            def configure(vagrantConfig)
                @vagrantConfig = vagrantConfig
                registeredModules = @moduleRegistry.registeredModules()
                if registeredModules
                    registeredModules.each do |moduleName|
                        @vagrantConfigInstance = nil
                        configureRegisteredModule(moduleName, getModuleConfiguration(moduleName))
                    end
                end
            end

            private
            def configureRegisteredModule(moduleName, moduleConfiguration)
                configureVagrantConfigScript(moduleName, moduleConfiguration)
                configureInitScript(moduleName, moduleConfiguration)
                configureShellScript(moduleName, moduleConfiguration)
            end

            def configureInitScript(moduleName, moduleConfiguration)
                initScriptPath = getModuleInitScript(moduleName)

                if initScriptPath
                    require initScriptPath
                    createInitInstance(moduleName, moduleConfiguration)
                else
                    @logger.debug "No init script for module #{moduleName}"
                end
            end

            def configureVagrantConfigScript(moduleName, moduleConfiguration)
                vagrantConfigScriptPath = getModuleVagrantConfigScript(moduleName)

                if vagrantConfigScriptPath
                    require vagrantConfigScriptPath
                    @vagrantConfigInstance = createInstanceInNamespace(moduleName, moduleConfiguration, '::Vagrant::Config')
                else
                    @logger.debug "No Vagrant config script for module #{moduleName}"
                end
            end

            def getModuleConfiguration(moduleName)
                config = Dup::Core::Config.instance
                moduleConfiguration = config.get()['modules'][moduleName]

# puts "---------------------------------------------------------------------------------------------------------------------"
#                 puts 'MC ' +  moduleName + ' ', config.get()['modules'], config.get()['modules'][moduleName]
#
# puts "---------------------------------------------------------------------------------------------------------------------"
                if moduleConfiguration.nil?
                    return {}
                elsif moduleConfiguration.is_a? Array
                    abort "Can not transform array to module configuration. Please check your YAML files"
                elsif moduleConfiguration.is_a? String
                    abort "Can not transform array to module configuration. Please check your YAML files"
                elsif moduleConfiguration.is_a? Numeric
                    abort "Can not transform array to module configuration. Please check your YAML files"
                elsif moduleConfiguration.is_a? Hash
                    return moduleConfiguration
                else
                    return {}
                end
            end

            def configureShellScript(moduleName, moduleConfiguration)
                privileged = !!moduleConfiguration['privileged']

                env = getScriptEnvironment()
                env = env.deep_merge(moduleConfiguration)
                if @vagrantConfigInstance && @vagrantConfigInstance.respond_to?('prepareEnvironmentVariables')
                    env.deep_merge!(@vagrantConfigInstance.prepareEnvironmentVariables(env))
                end

                @vagrantConfig.vm.provision("module/#{moduleName}", type: "shell", privileged: privileged, path: getModuleShellScript(moduleName), env: env, run: "always")
            end

            def getModuleInitScript(moduleName)
                moduleDirectoryPath = @moduleRegistry.getModuleDirectory(moduleName)

                if File.exists?("#{moduleDirectoryPath}/init.rb")
                    return "#{moduleDirectoryPath}/init.rb"
                end

                return nil
            end

            def getModuleVagrantConfigScript(moduleName)
                moduleDirectoryPath = @moduleRegistry.getModuleDirectory(moduleName)

                if File.exists?("#{moduleDirectoryPath}/vagrant/config.rb")
                    return "#{moduleDirectoryPath}/vagrant/config.rb"
                end

                return nil
            end

            def getModuleShellScript(moduleName)
                moduleDirectoryPath = @moduleRegistry.getModuleDirectory(moduleName)

                if File.exists?("#{moduleDirectoryPath}/init.sh")
                    return "#{moduleDirectoryPath}/init.sh"
                end

                abort("Script for module '#{moduleName}' not found")
            end

            def createInstanceInNamespace(moduleName, moduleConfiguration, namespace)
                Object.const_get(ucFirst(moduleName) + namespace)
                .new(@vagrantConfig, moduleConfiguration)
            end

            def createInitInstance(moduleName, moduleConfiguration)
                return createInitInstanceInNamespace(moduleName, moduleConfiguration, '')
            end

            def ucFirst(moduleName)
                moduleDup = moduleName.dup
                moduleDup[0] = moduleDup[0,1].upcase
                return moduleDup
            end
        end
    end
end
