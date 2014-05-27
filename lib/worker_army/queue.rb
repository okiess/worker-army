require "redis"
require "rest-client"
require "json"
require "multi_json"
require "yaml"
require "logger"

module WorkerArmy
  class Queue
    attr_accessor :config

    def initialize
      @config = Queue.config
      # puts "Config: #{@config}"
      Queue.redis_instance
      @log = $WORKER_ARMY_LOG
    end

    class << self
      def config
        if ENV['worker_army_redis_host'] and ENV['worker_army_redis_port']
          config = { 'redis_host' => ENV['worker_army_redis_host'], 'redis_port' => ENV['worker_army_redis_port'] }
          if ENV['worker_army_redis_auth']
            config['redis_auth'] = ENV['worker_army_redis_auth']
          end
        else
          begin
            # puts "Using config in your home directory"
            config = YAML.load(File.read("#{ENV['HOME']}/.worker_army.yml"))
          rescue Errno::ENOENT
            raise "worker_army.yml expected in ~/.worker_army.yml"
          end
        end
        config
      end

      def redis_instance
        $config = Queue.config unless $config
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
        queue_count = Queue.redis_instance.incr("#{queue_name}_counter")
        Queue.redis_instance.rpush queue_name, data.merge(job_count: job_count,
          queue_count: queue_count, queue_name: queue_name).to_json
      end
      raise "No data" unless data
      raise "No redis connection!" unless Queue.redis_instance
      { job_count: job_count, queue_count: queue_count, queue_name: queue_name }
    end

    def pop(job_class_name, queue_prefix = "queue")
      raise "No redis connection!" unless Queue.redis_instance
      return Queue.redis_instance.blpop("#{queue_prefix}_#{job_class_name}")
    end

    def save_result(data)
      if data
        job_count = data['job_count']
        callback_url = data['callback_url']
        Queue.redis_instance["job_#{job_count}"] = data
        if callback_url
          data.delete("callback_url")
          begin
            response = RestClient.post callback_url.split("?callback_url=").last,
              data.to_json, :content_type => :json, :accept => :json
          rescue => e
            @log.error(e)
          end
        end
      end
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
      worker_pings = worker_pings.collect {|json| JSON.parse(json)}.sort {|h| h['timestamp']}.reverse
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
      workers
    end

    def get_job_count(queue_prefix = "queue")
      Queue.redis_instance["#{queue_prefix}_counter"]
    end
  end
end
