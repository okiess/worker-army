require "rest-client"
require "json"
require "multi_json"
require 'socket'
require File.dirname(__FILE__) + '/base'

module WorkerArmy
  class Worker < Base
    attr_accessor :queue, :job, :worker_name, :processed, :failed
    def initialize(job, worker_name = nil)
      @queue = WorkerArmy::Queue.new
      @job = job
      @worker_name = worker_name
      @host_name = Socket.gethostname
      @processed = 0
      @failed = 0
      @config = self.config
      @log = WorkerArmy::Log.new.log
    end

    def process_queue
      raise "No job class set!" unless @job
      @job.log = @log if @job.respond_to?(:log)
      @queue.ping(worker_pid: Process.pid, job_name: @job.class.name, host_name: @host_name,
        timestamp: Time.now.utc.to_i)
      @log.info("Worker #{@host_name}-#{Process.pid} => Queue: queue_#{@job.class.name}")
      @log.info("Worker #{@host_name}-#{Process.pid} => Processed: #{@processed} - Failed: #{@failed}")
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
          @queue.add_current_job(job_id)
          response_data = @job.perform(data)
          response_data = {} unless response_data
          response_data.merge!(job_id: job_id, callback_url: callback_url,
            finished_at: Time.now.utc.to_i, host_name: @host_name)
          @processed += 1
          if @worker_name
            response_data.merge!(worker_name: @worker_name)
          end
        end
        @queue.remove_current_job(job_id)
        response_data
      rescue => e
        @queue.remove_current_job(job_id)
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

    def worker_retry_count(conf = nil)
      if ENV['worker_army_worker_retry_count']
        return ENV['worker_army_worker_retry_count'].to_i
      elsif conf and conf['worker_retry_count']
        return conf['worker_retry_count'].to_i
      else
        return 10
      end
    end
  end
end
