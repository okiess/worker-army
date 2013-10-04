worker_processes 3
timeout 30
preload_app true

after_fork do |server, worker|
  Redis.current.quit
end