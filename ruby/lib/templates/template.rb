module Dup
    module Templates
        class Template
            def initialize(moduleName, name, content)
                @moduleName = moduleName
                @name = name
                @content = content
                @logger = Dup::Log::Logger.new()
            end

            def save()
                directoryPath = Dup::Core::Config.instance.sharedTempPath + "/#{@moduleName}"
                path = "#{directoryPath}/#{@name}"

                unless Dir.exists?(directoryPath)
                    Dir.mkdir(directoryPath, 0770)
                end

                @logger.debug "Open file path #{path} for writing"
                File.open(path, 'w') { |file| file.write(@content) }
            end
        end
    end
end
