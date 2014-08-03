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
        response = nil; response_data = { 'success' => false }
        begin
          response = RestClient.post "#{worker_army_base_url}/jobs",
            data.merge(
              job_class: job_class,
              callback_url: "#{worker_army_base_url}/callback?callback_url=#{callback_url}",
              queue_prefix: queue_prefix
            ).to_json,
            :content_type => :json, :accept => :json, "api_key" => config['api_key']
        rescue => e
          puts "Failed! Retrying (#{retry_count})..."
          retry_count += 1
          if retry_count < client_retry_count(config) and not e.message == '401 Unauthorized'
            sleep (retry_count * 2)
            push_job(job_class, data, callback_url, queue_prefix, retry_count)
          elsif e.message == "401 Unauthorized"
            response_data = response_data.merge('error_message' => '401 Unauthorized')
          end
        end
        if response and response.body and response.code == 200
          hash = JSON.parse(response.body)
          return hash.merge('success' => true)
        end
        response_data
      end
    end
  end
end
