require "redis"
require "rest-client"
require "json"
require "multi_json"
require "yaml"
require 'securerandom'
require File.dirname(__FILE__) + '/base'

module WorkerArmy
  class Queue < Base
    def initialize
      @config = config
      Queue.redis_instance
      @log = WorkerArmy::Log.new.log
    end

    class << self
      def redis_instance
        $config = config unless $config
        unless $redis
          $redis = Redis.new(host: $config['redis_host'], port: $config['redis_port'])
        end
        $redis.auth($config['redis_auth']) if $config['redis_auth']
        $redis
      end

      def close_redis_connection
        $redis.quit if $redis
        $redis = nil
      end
    end

    def push(data, queue_prefix = "queue")
      if Queue.redis_instance and data
        job_count = Queue.redis_instance.incr("#{queue_prefix}_counter")
        queue_prefix = queue_prefix if queue_prefix
        queue_prefix = data['queue_prefix'] if data['queue_prefix']
        queue_name = "#{queue_prefix}_#{data['job_class']}"
        Queue.redis_instance.sadd 'known_queues', queue_name
        queue_count = Queue.redis_instance.incr("#{queue_name}_counter")
        job_id = SecureRandom.uuid
        Queue.redis_instance.rpush queue_name, data.merge(job_count: job_count,
          queue_count: queue_count, job_id: job_id, queue_name: queue_name).to_json
      end
      raise "No data" unless data
      raise "No redis connection!" unless Queue.redis_instance
      { job_count: job_count, job_id: job_id, queue_count: queue_count,
        queue_name: queue_name }
    end

    def pop(job_class_name, queue_prefix = "queue")
      raise "No redis connection!" unless Queue.redis_instance
      return Queue.redis_instance.blpop("#{queue_prefix}_#{job_class_name}")
    end

    def save_result(data)
      if data
        job_id = data['job_id']
        callback_url = data['callback_url']
        if @config['store_job_data']
          Queue.redis_instance["job_#{job_id}"] = data.to_json
        end
        Queue.redis_instance.lpush 'jobs', job_id
        if callback_url
          data.delete("callback_url")
          deliver_callback(job_id, callback_url, data)
        end
      end
    end

    def deliver_callback(job_id, callback_url, data, retry_count = 0)
      begin
        response = RestClient.post callback_url.split("?callback_url=").last,
          data.to_json, :content_type => :json, :accept => :json
        if response.code == 404 or response.code == 500
          @log.error("Response from callback url: #{response.code}")
          add_failed_callback_job(job_id)
        end
      rescue => e
        @log.error(e)
        retry_count += 1
        if retry_count < callback_retry_count(@config)
          @log.debug("Delivering external callback failed! Retrying (#{retry_count})...")
          sleep (retry_count * 2)
          deliver_callback(job_id, callback_url, data, retry_count)
        else
          add_failed_callback_job(job_id)
        end
      end
    end

    def add_current_job(job_id)
      Queue.redis_instance.sadd 'current_jobs', job_id
    end

    def remove_current_job(job_id)
      Queue.redis_instance.srem 'current_jobs', job_id
    end
    
    def current_jobs_count
      Queue.redis_instance.scard 'current_jobs'
    end

    def current_jobs
      Queue.redis_instance.smembers 'current_jobs'
    end
    
    def clear_current_jobs
      Queue.redis_instance.del 'current_jobs'
    end

    def job_data(job_id)
      Queue.redis_instance["job_#{job_id}"]
    end

    def add_failed_job(job_id)
      Queue.redis_instance.lpush 'failed_jobs', job_id
    end

    def add_failed_callback_job(job_id)
      Queue.redis_instance.lpush 'failed_callback_jobs', job_id
    end

    def failed_jobs_count
      Queue.redis_instance.llen 'failed_jobs'
    end

    def failed_jobs
      Queue.redis_instance.lrange 'failed_jobs', 0, failed_jobs_count
    end

    def failed_callback_jobs_count
      Queue.redis_instance.llen 'failed_callback_jobs'
    end

    def failed_callback_jobs
      Queue.redis_instance.lrange 'failed_callback_jobs', 0, failed_callback_jobs_count
    end

    def ping(data)
      Queue.redis_instance.lpush 'workers', data.to_json
      Queue.redis_instance.set 'last_ping', data[:timestamp].to_i
    end

    def last_ping
      Queue.redis_instance.get 'last_ping'
    end

    def get_known_workers(recent_worker_pings = 1000)
      worker_pings = Queue.redis_instance.lrange 'workers', 0, recent_worker_pings
      return [] unless worker_pings
      worker_pings = worker_pings.collect {|json| JSON.parse(json)}.sort_by {|h| h['timestamp'].to_i}.reverse
      uniq_workers = worker_pings.collect {|h| [h['host_name'], h['worker_pid']]}.uniq
      workers = []
      uniq_workers.each do |worker_pair|
        worker_pings.each do |hash|
          if hash['host_name'] == worker_pair[0] and hash['worker_pid'] == worker_pair[1]
            workers << hash
            break
          end
        end
      end
      now = Time.now.utc.to_i
      workers.select {|h| h if now - h['timestamp'].to_i < 3600}
    end

    def get_known_queues
      Queue.redis_instance.smembers 'known_queues'
    end

    def finished_jobs_count
      Queue.redis_instance.llen 'jobs'
    end

    def get_job_count(queue_prefix = "queue")
      Queue.redis_instance["#{queue_prefix}_counter"].to_i
    end
  end
end
