module WorkerArmy
  class Base
    attr_accessor :config

    class << self
      def config
        if ENV['worker_army_redis_host'] and ENV['worker_army_redis_port']
          config = { 'redis_host' => ENV['worker_army_redis_host'], 'redis_port' => ENV['worker_army_redis_port'] }
          if ENV['worker_army_redis_auth']
            config['redis_auth'] = ENV['worker_army_redis_auth']
          end
          if ENV['worker_army_worker_retry_count']
            config['worker_retry_count'] = ENV['worker_army_worker_retry_count'].to_i
          end
          if ENV['worker_army_client_retry_count']
            config['client_retry_count'] = ENV['worker_army_client_retry_count'].to_i
          end
          if ENV['worker_army_endpoint']
            config['endpoint'] = ENV['worker_army_endpoint']
          end
        else
          begin
            # puts "Using config in your home directory"
            config = YAML.load(File.read("#{ENV['HOME']}/.worker_army.yml"))
          rescue Errno::ENOENT
            raise "worker-army configuration expected in ~/.worker_army.yml or provide env vars..."
          end
        end
        config
      end
    end  
  end
end