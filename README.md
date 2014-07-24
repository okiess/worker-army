# worker-army

worker-army is a simple redis based worker queue written in ruby for running background jobs with a HTTP/REST interface. It doesn't have any ties to Ruby on Rails and aims to be lightweight and memory efficient.

worker-army is work in progress and not yet production-ready!

## Installation

To install worker-army, add the gem to your Gemfile:

    gem "worker-army"

Then run `bundle`. If you're not using Bundler, just `gem install worker-army`.

## Requirements

* Ruby 2.1
* Redis 2.x

## Configuration

Checkout `worker_army.yml.sample` on the available configuration options. Then create your own `~/.worker_army.yml` file.

If you can't provide or don't want to provide the config file at that location, you can also set environment variables (when you're deploying on heroku for example):

     worker_army_endpoint
     worker_army_redis_host
     worker_army_redis_port
     worker_army_redis_auth
     worker_army_worker_retry_count
     worker_army_client_retry_count
     worker_army_callback_retry_count
     worker_army_store_job_data

## Server / Queue

Start the worker-army server by executing:

    $ worker_army
    
or use Foreman (checkout `Procfile`)

    $ foreman start

You easily run the worker-army server on heroku. It should work out of the box (you'll need to setup a redis database though). You're just going to have provide the configuration environment variables.

You can open the server status overview by calling the server root url:

http://your-worker-army-server.com/

The status overview returns JSON, so you can easily embed it into your own applications.

To view the result of a single job execution:

http://your-worker-army-server.com/jobs/YOUR_JOB_ID

## Client

You can push jobs onto the queue with this ruby client (or any other HTTP REST capable mechanism). The ruby client will communicate with the server from anywhere:

    WorkerArmy::Client.push_job("ExampleJob", {"foo" => "bar"}, "http://your-callback-server.com/data-callback?some_id=1234")

Provide an (optional) URL as the last argument and worker-army will return the job result to the URL as a HTTP POST callback.

## Workers

You can start up a worker with numerous job classes assigned to it with the following:

    $ rake start_worker ExampleJob AnotherJob

## Jobs

Jobs are just regular ruby classes that look like this:

    class ExampleJob
      attr_accessor :log
      
      def perform(data = {})
        # Your Code
      end
    end
    
This is how the data looks like for example that the worker passes into the `perform` method:

    {
      "foo"=>"bar",
      "job_class"=>"ExampleJob",
      "callback_url"=>"http://your-worker-army-server.com/callback?callback_url=http://your-callback-server.com/data-callback?some_id=1234",
      "queue_prefix"=>"queue",
      "job_count"=>1081,
      "queue_count"=>1,
      "job_id"=>"9192a85e-320d-4e15-bdc5-2fa41e862370",
      "queue_name"=>"queue_ExampleJob"
    }

The client who created the job will get this in return:

    {
      "job_count"=>1081,
      "job_id"=>"9192a85e-320d-4e15-bdc5-2fa41e862370",
      "queue_count"=>1,
      "queue_name"=>"queue_ExampleJob",
      "success"=>true
    }
    
The `success` field indicates if the job creation (not the execution!) was successfull.

The result of the job execution will be provided via the callback or by manually calling the job data URL (http://your-worker-army-server.com/jobs/YOUR_JOB_ID).

## Logging

Per default, worker-army will create a log file in /tmp/worker-army.log.

## Copyright

Copyright (c) 2013-2014 Oliver Kiessler. See LICENSE.txt for further details.
