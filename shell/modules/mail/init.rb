class Mail
    def initialize(vagrantConfig, moduleConfiguration)
        # Forward the GUI port for MailHog
        if moduleConfiguration['mailhog_setup']
            vagrantConfig.vm.network "forwarded_port", guest: "8025", host: "8025"
        end
    end

end
