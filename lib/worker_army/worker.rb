require "rest-client"
require "json"
require "multi_json"
require 'socket'

module WorkerArmy
  class Worker
    attr_accessor :queue, :job, :worker_name, :processed, :failed, :config
    def initialize(worker_name = nil)
      @queue = WorkerArmy::Queue.new
      @worker_name = worker_name
      @host_name = Socket.gethostname
      @processed = 0
      @failed = 0
      begin
        # puts "Using config in your home directory"
        @config = YAML.load(File.read("#{ENV['HOME']}/.worker_army.yml"))
      rescue Errno::ENOENT
        # ignore
      end
      @log = $WORKER_ARMY_LOG
    end

    def process_queue
      raise "No job class set!" unless @job
      @job.log = @log if @job.respond_to?(:log)
      @queue.ping(worker_pid: Process.pid, job_name: @job.class.name, host_name: @host_name,
        timestamp: Time.now.utc.to_i)
      @log.info("Worker ready! Waiting for jobs: #{@job.class.name}")
      @log.info("Processed: #{@processed} - Failed: #{@failed}")
      list, element = @queue.pop(@job.class.name)
      if list and element
        execute_job(list, element, 0)
      end
    end

    private
    def execute_job(list, element, retry_count = 0)
      @log.debug("Queue: #{list} => #{element}") if retry_count == 0
      response_data = {}
      job_count = 0
      begin
        data = JSON.parse(element)
        job_id = data['job_id']
        callback_url = data['callback_url']
        if @job and @job.class.name == data['job_class']
          response_data = @job.perform(data)
          response_data = {} unless response_data
          response_data.merge!(job_id: job_id, callback_url: callback_url,
            finished_at: Time.now.utc.to_i, host_name: @host_name)
          @processed += 1
          if @worker_name
            response_data.merge!(worker_name: @worker_name)
          end
        end
        response_data
      rescue => e
        @log.error(e)
        retry_count += 1
        if retry_count < worker_retry_count(@config)
          @log.debug("Failed! Retrying (#{retry_count})...")
          sleep (retry_count * 2)
          execute_job(list, element, retry_count)
        else
          @failed += 1
          @queue.add_failed_job(job_id)
        end
      end
      begin
        response = RestClient.post data['callback_url'],
          response_data.to_json, :content_type => :json, :accept => :json
      rescue => e
        @log.error(e)
      end
      self.process_queue
    end

    def worker_retry_count(config = nil)
      if ENV['worker_army_worker_retry_count']
        return ENV['worker_army_worker_retry_count'].to_i
      elsif config and config['worker_retry_count']
        return config['worker_retry_count'].to_i
      else
        return 10
      end
    end
  end
end
