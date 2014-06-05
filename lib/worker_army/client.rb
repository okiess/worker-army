require "rest-client"
require "json"
require "multi_json"
require File.dirname(__FILE__) + '/base'

module WorkerArmy
  class Client < Base
    class << self
      def push_job(job_class, data = {}, callback_url = nil, queue_prefix = 'queue', retry_count = 0)
        raise "No data" unless data
        raise "No job class provided" unless job_class
        worker_army_base_url = config['endpoint']
        callback_url = "#{worker_army_base_url}/generic_callback" unless callback_url
        response = nil
        begin
          response = RestClient.post "#{worker_army_base_url}/jobs",
            data.merge(
              job_class: job_class,
              callback_url: "#{worker_army_base_url}/callback?callback_url=#{callback_url}",
              queue_prefix: queue_prefix
            ).to_json,
            :content_type => :json, :accept => :json
        rescue => e
          puts "Failed! Retrying (#{retry_count})..."
          retry_count += 1
          if retry_count < client_retry_count(config)
            sleep (retry_count * 2)
            push_job(job_class, data, callback_url, queue_prefix, retry_count)
          end
        end
        if response and response.body and response.code == 200
          hash = JSON.parse(response.body)
          hash.merge('success' => true)
        else
          { 'success' => false }
        end
      end
    end
  end
end
