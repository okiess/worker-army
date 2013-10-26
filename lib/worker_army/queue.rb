require "redis"
require "rest-client"
require "json"
require "multi_json"
require "yaml"

module WorkerArmy
  class Queue
    attr_accessor :config
  
    def initialize

      @config = Queue.config
      puts "Config: #{@config}"
      Queue.redis_instance
    end
    
    def self.config
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

    def self.redis_instance
      unless $redis
        config = Queue.config
        $redis = Redis.new(host: config['redis_host'], port: config['redis_port'])
      end
      $redis.auth(config['redis_auth']) if config['redis_auth']
      $redis
    end

    def self.close_redis_connection
      $redis.quit if $redis
      $redis = nil
    end

    def push(data, queue_name = "queue")
      if Queue.redis_instance and data
        job_count = Queue.redis_instance.incr("#{queue_name}_counter")
        queue_name = data['queue_name'] if data['queue_name']
        queue_name = "#{queue_name}_#{data['job_class']}"
        Queue.redis_instance.rpush queue_name, data.merge(job_count: job_count).to_json
      end
      raise "No data" unless data
      raise "No redis connection!" unless Queue.redis_instance
    end
    
    def pop(queue_name = "queue")
      raise "No redis connection!" unless Queue.redis_instance
      return Queue.redis_instance.blpop(queue_name)
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
            puts e
          end
        end
      end
    end

    def get_job_count(queue_name = "queue")
      Queue.redis_instance["#{queue_name}_counter"]
    end
  end
end
