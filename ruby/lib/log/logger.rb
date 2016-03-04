module Dup
    module Log
        class Logger
            def loggerInstance
                begin
                    require "log4r"
                    @loggerInstance = Log4r::Logger.new("vagrant::ui::interface")
                rescue LoadError
                    @loggerInstance = nil
                end
                @loggerInstance
            end

            def debug(message)
                if self.loggerInstance
                    self.loggerInstance.debug(message)
                end
            end

            def info(message)
                if self.loggerInstance
                    self.loggerInstance.info(message)
                end
            end

            def warn(message)
                if self.loggerInstance
                    self.loggerInstance.warn(message)
                end
            end

            def error(message)
                if self.loggerInstance
                    self.loggerInstance.error(message)
                end
            end

            def fatal(message)
                if self.loggerInstance
                    self.loggerInstance.fatal(message)
                end
            end

        end
    end
end
