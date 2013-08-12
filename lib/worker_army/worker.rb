require "rest-client"
require "json"
require "multi_json"

module WorkerArmy
  class Worker
    attr_accessor :queue, :job
    def initialize
      @queue = WorkerArmy::Queue.new
    end
    
    def process_queue
      list, element = @queue.pop
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
            response_data.merge!(job_count: job_count, callback_url: callback_url)
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
