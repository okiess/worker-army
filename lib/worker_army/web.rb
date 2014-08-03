require "json"
require "multi_json"
require "sinatra"
require "sinatra/json"
require "sinatra/basic_auth"
require File.dirname(__FILE__) + '/log'
require File.dirname(__FILE__) + '/queue'

queue = WorkerArmy::Queue.new
auth = false
if queue.config['use_basic_auth'] and queue.config['basic_auth_username'] and queue.config['basic_auth_password']
  authorize do |username, password|
    username == queue.config['basic_auth_username'] && password == queue.config['basic_auth_password']
  end
  auth = true
end

before do
  content_type 'application/json', :charset => 'utf-8'
end

def overview(queue)
  job_count = queue.get_job_count || 0
  workers = queue.get_known_workers
  last_ping = queue.last_ping || 0
  queues = queue.get_known_queues
  finished_jobs = queue.finished_jobs_count
  failed_callback_jobs = queue.failed_callback_jobs_count
  failed_jobs = queue.failed_jobs_count
  current_jobs = queue.current_jobs
  data = { job_count: job_count, finished_jobs: finished_jobs,
    failed_jobs: failed_jobs, failed_callback_jobs: failed_callback_jobs,
    workers: workers, last_worker_ping: last_ping.to_i, queues: queues,
    current_jobs: current_jobs
  }
end

if auth
  protect do
    get "/" do
      json overview(queue)
    end
  end
else
  get '/' do
    json overview(queue)
  end
end

post '/jobs' do
  unless request.env['HTTP_API_KEY'] == queue.config['api_key']
    halt 401, "Not authorized\n"
  end
  data = JSON.parse(request.body.read)
  queue_job = queue.push data if data
  json queue_job
end

get '/jobs/:job_id' do
  data = queue.job_data(params[:job_id])
  json data ? JSON.parse(data): {}
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

get '/failed_jobs' do
  failed_jobs = queue.failed_jobs
  json failed_jobs
end

get '/failed_callback_jobs' do
  failed_callback_jobs = queue.failed_callback_jobs
  json failed_callback_jobs
end
