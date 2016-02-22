module Mail
    module Vagrant
        class Config
            def initialize(vagrantConfig, moduleConfiguration)
                ## Example:
                ## Forward the GUI port for MailHog
                # if moduleConfiguration['mailhog_setup']
                #     vagrantConfig.vm.network "forwarded_port", guest: "8025", host: "8025"
                # end
            end
        end
    end
end
