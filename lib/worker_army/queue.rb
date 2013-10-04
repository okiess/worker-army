require "redis"
require "rest-client"
require "json"
require "multi_json"
require "yaml"

module WorkerArmy
  class Queue
    attr_accessor :redis, :config
  
    def initialize
      if ENV['worker_army_redis_host'] and ENV['worker_army_redis_port']
        @config = { 'redis_host' => ENV['worker_army_redis_host'], 'redis_port' => ENV['worker_army_redis_port'] }
      else
        begin
          puts "Using config in your home directory"
          @config = YAML.load(File.read("#{ENV['HOME']}/.worker_army.yml"))
        rescue Errno::ENOENT
          raise "worker_army.yml expected in ~/.worker_army.yml"
        end
      end
      puts "Config: #{@config}"
      @redis = Redis.new(host: @config['redis_host'], port: @config['redis_port'])
    end

    def push(data, queue_name = "queue")
      if @redis and data
        job_count = @redis.incr("#{queue_name}_counter")
        @redis.rpush queue_name, data.merge(job_count: job_count).to_json
      end
      raise "No data" unless data
      raise "No redis connection!" unless @redis
    end
    
    def pop(queue_name = "queue")
      raise "No redis connection!" unless @redis
      return @redis.blpop(queue_name)
    end
    
    def save_result(data)
      if data
        job_count = data['job_count']
        callback_url = data['callback_url']
        @redis["job_#{job_count}"] = data
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
      @redis["#{queue_name}_counter"]
    end
  end
end
