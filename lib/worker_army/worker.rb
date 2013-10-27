require "rest-client"
require "json"
require "multi_json"
require 'socket'

module WorkerArmy
  class Worker
    attr_accessor :queue, :job, :worker_name
    def initialize(worker_name = nil)
      @queue = WorkerArmy::Queue.new
      @worker_name = worker_name
      @host_name = Socket.gethostname
    end

    def process_queue
      raise "No job class set!" unless @job
      list, element = @queue.pop(@job.class.name)
      if list and element
        puts "List: #{list} => #{element}"
        response_data = {}
        job_count = 0
        begin
          data = JSON.parse(element)
          job_count = data['job_count']
          callback_url = data['callback_url']
          if @job and @job.class.name == data['job_class']
            response_data = @job.perform(data)
            response_data.merge!(job_count: job_count, callback_url: callback_url,
              finished_at: Time.now.utc.to_i, host_name: @host_name)
            if @worker_name
              response_data.merge!(worker_name: @worker_name)
            end
          end
        rescue => e
          puts e
        end
        if response_data
          begin
            response = RestClient.post data['callback_url'],
              response_data.to_json, :content_type => :json, :accept => :json
          rescue => e
            puts e
          end
        end
        self.process_queue
      end
    end
  end
end
