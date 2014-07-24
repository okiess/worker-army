require "rest-client"
require "json"
require "multi_json"
require 'socket'
require File.dirname(__FILE__) + '/base'

module WorkerArmy
  class Worker < Base
    attr_accessor :queue, :jobs, :job_names, :worker_name, :processed, :failed
    def initialize(jobs, worker_name = nil)
      @queue = WorkerArmy::Queue.new
      @log = WorkerArmy::Log.new.log
      @job_names = []
      @jobs = jobs
      if @jobs and @jobs.size > 0
        @jobs.each do |job|
          job.log = @log if job.respond_to?(:log)
          @job_names << job.class.name
        end
      end
      @job_names = @job_names.uniq
      @worker_name = worker_name
      @host_name = Socket.gethostname
      @processed = 0
      @failed = 0
      @config = self.config
    end

    def process_queue
      raise "No job classes set!" if @jobs.nil? or @jobs.size == 0
      @jobs.each do |job|
        @queue.ping(worker_pid: Process.pid, job_name: job.class.name, host_name: @host_name,
          timestamp: Time.now.utc.to_i)
        @log.info("Worker #{@host_name}-#{Process.pid} => Queue: queue_#{job.class.name}")
      end
      @log.info("Worker #{@host_name}-#{Process.pid} => Processed: #{@processed} - Failed: #{@failed}")
      list, element = @queue.pop(@jobs)
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
        if @jobs and @job_names.include?(data['job_class'])
          @queue.add_current_job(job_id)
          started_at = Time.now.utc.to_i
          response_data = @jobs.select {|j| j.class.name == data['job_class']}.first.perform(data)
          response_data = {} unless response_data
          if callback_url and not callback_url.empty?
            response_data.merge!(callback_url: callback_url)
          end
          response_data.merge!(job_id: job_id, started_at: started_at,
            finished_at: Time.now.utc.to_i, host_name: @host_name,
            worker_pid: Process.pid)
          if @worker_name
            response_data.merge!(worker_name: @worker_name)
          end
          @processed += 1
        end
        @queue.remove_current_job(job_id)
      rescue => e
        @queue.remove_current_job(job_id)
        @log.error(e)
        retry_count += 1
        if retry_count < worker_retry_count(@config)
          @log.debug("Job execution failed! Retrying (#{retry_count})...")
          sleep (retry_count * 2)
          execute_job(list, element, retry_count)
        else
          @failed += 1
          @queue.add_failed_job(job_id)
        end
      end
      if callback_url and not callback_url.empty?
        deliver_callback(data, response_data)
      end
      self.process_queue
    end

    def deliver_callback(data, response_data, retry_count = 0)
      begin
        response = RestClient.post data['callback_url'],
          response_data.to_json, :content_type => :json, :accept => :json
      rescue => e
        @log.error(e)
        retry_count += 1
        if retry_count < callback_retry_count(@config)
          @log.debug("Delivering worker-army callback failed! Retrying (#{retry_count})...")
          sleep (retry_count * 2)
          deliver_callback(data, response_data, retry_count)
        end
      end
    end
  end
end
