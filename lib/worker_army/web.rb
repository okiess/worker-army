require "json"
require "multi_json"
require "sinatra"
require "sinatra/json"
require File.dirname(__FILE__) + '/log'
require File.dirname(__FILE__) + '/queue'

$WORKER_ARMY_LOG = WorkerArmy::Log.new.log

queue = WorkerArmy::Queue.new

get '/' do
  job_count = queue.get_job_count || 0
  workers = queue.get_known_workers
  last_ping = queue.last_ping || 0
  queues = queue.get_known_queues
  finished_jobs = queue.finished_jobs
  failed_jobs = queue.failed_jobs
  data = { job_count: job_count, finished_jobs: finished_jobs,
    failed_jobs: failed_jobs, workers: workers,
    last_worker_ping: last_ping.to_i, queues: queues
  }
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
