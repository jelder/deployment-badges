require 'bundler'
Bundler.require

$redis = Redis.new(url: ENV.fetch("OPENREDIS_URL", "redis://127.0.0.1:6379"), driver: :hiredis)

class DeploymentBadges < Sinatra::Base
  require "sinatra/reloader" if development?

  set :haml, { :ugly => production?, :format => :html5 }
  set :public_folder, File.dirname(__FILE__) + '/static'

  post '/' do

  end



end
