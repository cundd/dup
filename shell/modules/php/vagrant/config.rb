module Php
    module Vagrant
        class Config < Dup::Core::ConfigurationInstance
            def initialize(vagrantConfig, moduleConfiguration)
                @moduleConfiguration = moduleConfiguration
                ## Example:
                ## Forward the GUI port for MailHog
                # if moduleConfiguration['mailhog_setup']
                #     vagrantConfig.vm.network "forwarded_port", guest: "8025", host: "8025"
                # end
            end

            def prepareEnvironmentVariables(env)
                addPhpIniToEnvironment(env)
                addPhpFeaturesToEnvironment(env)
                return {}
            end

            def addPhpIniToEnvironment(env)
                env['PHP_CUSTOM_INI'] = phpIni.join(";")
            end

            def phpIni
                phpCustomIni = []
                @moduleConfiguration['ini'].each do |name, value|
                    phpCustomIni.push("#{name}=#{value}")
                end
                return phpCustomIni
            end

            def addPhpFeaturesToEnvironment(env)
                phpFeatures = @moduleConfiguration['features']

                phpFeatures.each do |key, value|
                    env['PHP_FEATURE_' + key.upcase] = value
                end
            end
        end
    end
end
