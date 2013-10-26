require "rest-client"
require "json"
require "multi_json"

module WorkerArmy
  class Client
    def self.push_job(job_class, data = {}, callback_url = nil, queue_name = 'queue')
      raise "No data" unless data
      raise "No job class provided" unless job_class
      
      if ENV['worker_army_endpoint']
        puts "Using environment variables for config..."
        @config = { endpoint: ENV['worker_army_endpoint'] }
      else
        begin
          puts "Using config in your home directory"
          @config = YAML.load(File.read("#{ENV['HOME']}/.worker_army.yml"))
        rescue Errno::ENOENT
          raise "worker_army.yml expected in ~/.worker_army.yml"
        end
      end

      worker_army_base_url = @config['endpoint']
      callback_url = "#{worker_army_base_url}/generic_callback" unless callback_url
      response = RestClient.post "#{worker_army_base_url}/jobs",
        data.merge(
          job_class: job_class,
          callback_url: "#{worker_army_base_url}/callback?callback_url=#{callback_url}",
          queue_name: queue_name
        ).to_json,
        :content_type => :json, :accept => :json
      response.code == 200
    end
  end
end
