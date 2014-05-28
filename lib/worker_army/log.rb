module WorkerArmy
  class Log
    attr_accessor :log

    def initialize
      self.log = Logger.new('/tmp/worker-army.log')
      self.log.level = Logger::DEBUG
    end
  end
end
