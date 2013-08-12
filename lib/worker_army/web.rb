require "json"
require "multi_json"
require "sinatra"
require "sinatra/json"
require File.dirname(__FILE__) + '/queue'

queue = WorkerArmy::Queue.new

get '/' do
  job_count = queue.get_job_count || 0
  data = { :job_count => job_count }
  json data
end

post '/jobs' do
  data = JSON.parse(request.body.read)
  queue.push data if data
  json data
end

post '/callback' do
  data = JSON.parse(request.body.read)
  queue.save_result(data) if data
  json data
end
