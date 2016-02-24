module Dup
    class Modules
        def initialize(vagrantConfig)
            require "log4r"
            
            @vagrantConfig = vagrantConfig
            @logger = Log4r::Logger.new("vagrant::ui::interface")
        end

        def configure
            registeredModules = getConfig()['modules']
            if registeredModules
                registeredModules.each do |key, value|
                    configureRegisteredModule(key, prepareModuleConfiguration(value))
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
                createInstanceInNamespace(moduleName, moduleConfiguration, '::Vagrant::Config')
            else
                @logger.debug "No Vagrant config script for module #{moduleName}"
            end
        end

        def prepareModuleConfiguration(moduleConfiguration)
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

            @vagrantConfig.vm.provision("module/#{moduleName}", type: "shell", privileged: privileged, path: getModuleShellScript(moduleName), env: env, run: "always")
        end

        def getModuleInitScript(moduleName)
            moduleDirectoryPath = getModuleDirectory(moduleName)

            if File.exists?("#{moduleDirectoryPath}/init.rb")
                return "#{moduleDirectoryPath}/init.rb"
            end

            return nil
        end

        def getModuleVagrantConfigScript(moduleName)
            moduleDirectoryPath = getModuleDirectory(moduleName)

            if File.exists?("#{moduleDirectoryPath}/vagrant/config.rb")
                return "#{moduleDirectoryPath}/vagrant/config.rb"
            end

            return nil
        end

        def getModuleShellScript(moduleName)
            moduleDirectoryPath = getModuleDirectory(moduleName)

            if File.exists?("#{moduleDirectoryPath}/init.sh")
                return "#{moduleDirectoryPath}/init.sh"
            end

            abort("Script for module '#{moduleName}' not found")
        end

        def getModuleDirectory(moduleName)
            dir = File.dirname(File.expand_path(__FILE__))

            userModulesPath = "#{dir}/../../provision/modules"
            builtinModulesPath = "#{dir}/../shell/modules"

            if File.directory?("#{userModulesPath}/#{moduleName}")
                return "#{userModulesPath}/#{moduleName}"
            elsif File.directory?("#{builtinModulesPath}/#{moduleName}")
                return "#{builtinModulesPath}/#{moduleName}"
            end

            abort("Module '#{moduleName}' not found")
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
