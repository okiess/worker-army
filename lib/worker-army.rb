require "redis"
require "logger"

module WorkerArmy
  class Log
    attr_accessor :log

    def initialize
      self.log = Logger.new('/tmp/worker-army.log')
      self.log.level = Logger::DEBUG
    end
  end
end

$WORKER_ARMY_LOG = WorkerArmy::Log.new.log

require File.dirname(__FILE__) + '/worker_army/queue'
require File.dirname(__FILE__) + '/worker_army/worker'
require File.dirname(__FILE__) + '/worker_army/client'
require File.dirname(__FILE__) + '/worker_army/example_job'
