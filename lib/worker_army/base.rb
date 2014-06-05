module WorkerArmy
  class Base
    class << self
      def config
        return $config if $config
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
          if ENV['worker_army_callback_retry_count']
            config['callback_retry_count'] = ENV['worker_army_callback_retry_count'].to_i
          end
          if ENV['worker_army_endpoint']
            config['endpoint'] = ENV['worker_army_endpoint']
          end
          if ENV['worker_army_store_job_data']
            config['store_job_data'] = (ENV['worker_army_store_job_data'] == 'true')
          end
        else
          begin
            # puts "Using config in your home directory"
            config = YAML.load(File.read("#{ENV['HOME']}/.worker_army.yml"))
          rescue Errno::ENOENT
            raise "worker-army configuration expected in ~/.worker_army.yml or provide env vars..."
          end
        end
        $config = config
      end

      def client_retry_count(conf = nil)
        if ENV['worker_army_client_retry_count']
          return ENV['worker_army_client_retry_count'].to_i
        elsif conf and conf['client_retry_count']
          return conf['client_retry_count'].to_i
        else
          return 10
        end
      end
    end

    def config
      WorkerArmy::Base.config
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

    def callback_retry_count(conf = nil)
      if ENV['worker_army_callback_retry_count']
        return ENV['worker_army_callback_retry_count'].to_i
      elsif conf and conf['callback_retry_count']
        return conf['callback_retry_count'].to_i
      else
        return 3
      end
    end  
  end
end
