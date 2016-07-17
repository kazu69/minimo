require 'logger'

module Minimo
  class Logger
    def initialize(dir, level = ::Logger::INFO)
      @dir, @level = dir, level
    end

    def write(msg)
      logger = ::Logger.new(File.new("#{@dir}/minimo.log", 'a+'), 'daily')
      logger.level = @level
      logger.info msg
      logger.close
    end
  end
end