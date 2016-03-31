module Networking
    module Vagrant
        class Config < Dup::Core::ConfigurationInstance
            def initialize(vagrantConfig, moduleConfiguration)
                @moduleConfiguration = moduleConfiguration
            end

            def prepareEnvironmentVariables(env)
                createTemplateFileFromHostsConfiguration()
                return {}
            end

            def createTemplateFileFromHostsConfiguration()
                hosts = @moduleConfiguration['hosts']
                content = ''

                hosts.each do |key, value|
                    content += "#{key}\t#{value}\n"
                end

                Dup::Templates::Template.new("networking", "hosts", content).save()
            end
        end
    end
end
