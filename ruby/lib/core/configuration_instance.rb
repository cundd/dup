module Dup
    module Core
        class ConfigurationInstance
            def initialize(vagrantConfig, moduleConfiguration)
                ## Example:
                ## Forward the GUI port for MailHog
                # if moduleConfiguration['mailhog_setup']
                #     vagrantConfig.vm.network "forwarded_port", guest: "8025", host: "8025"
                # end
            end

            def prepareEnvironmentVariables(env)
                return {}
            end
        end
    end
end
