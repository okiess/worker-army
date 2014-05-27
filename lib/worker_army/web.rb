require "json"
require "multi_json"
require "sinatra"
require "sinatra/json"
require File.dirname(__FILE__) + '/queue'

queue = WorkerArmy::Queue.new

get '/' do
  job_count = queue.get_job_count || 0
  workers = queue.get_known_workers
  last_ping = queue.last_ping || 0
  data = { job_count: job_count, workers: workers,
    last_ping: last_ping.to_i  }
  json data
end

post '/jobs' do
  data = JSON.parse(request.body.read)
  queue_job = queue.push data if data
  json queue_job
end

post '/callback' do
  data = JSON.parse(request.body.read)
  queue.save_result(data) if data
  json data
end

post '/generic_callback' do
  data = JSON.parse(request.body.read)
  status = { :status => 'ok' }
  json status
end
