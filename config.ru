require 'rubygems'
require 'bundler'
Bundler.require

#ENV['RACK_ENV']="production"
require './sinatra_todo'

use Rack::ShowExceptions
run Sinatra::Application
