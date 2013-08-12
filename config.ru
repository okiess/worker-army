require 'rubygems'
require 'sinatra'
require File.expand_path '../lib/worker_army/web', __FILE__

run Sinatra::Application
