worker_processes 3
timeout 30
preload_app true

before_fork do |server, worker|
  WorkerArmy::Queue.close_redis_connection
end

after_fork do |server, worker|
  WorkerArmy::Queue.redis_instance
end
