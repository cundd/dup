module Dup
    module Modules
        class Registry
            def initialize(configurationInstance = nil)
                if configurationInstance
                    @configurationInstance = configurationInstance
                end
                @logger = Log4r::Logger.new("vagrant::ui::interface")
            end

            def registeredModules
                self.configurationInstance.coreConfiguration['registeredModules']
            end

            def getModuleDirectory(moduleName)
                config = self.configurationInstance

                userModulesPath = "#{config.projectBasePath}/provision/shell/modules"
                builtinModulesPath = "#{config.basePath}/shell/modules"

                if File.directory?("#{userModulesPath}/#{moduleName}")
                    return "#{userModulesPath}/#{moduleName}"
                elsif File.directory?("#{builtinModulesPath}/#{moduleName}")
                    return "#{builtinModulesPath}/#{moduleName}"
                end

                abort("Module '#{moduleName}' not found")
            end

            def configurationInstance
                if not @configurationInstance
                    @configurationInstance = Dup::Core::Config.instance

                end
                @configurationInstance
            end
        end
    end
end
