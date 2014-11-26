require 'bundler'
Bundler.require

Dir[File.expand_path('../lib/*.rb',  __FILE__)].each { |f| require f }

$redis = Redis.new(url: ENV.fetch("REDISCLOUD_URL", "redis://127.0.0.1:6379"), driver: :hiredis)

class DeploymentBadges < Sinatra::Base
  require "sinatra/reloader" if development?

  set :haml, { :ugly => production?, :format => :html5 }
  set :public_folder, File.dirname(__FILE__) + '/static'
  
  configure :development do
    use BetterErrors::Middleware
    BetterErrors.application_root = __dir__

    register Sinatra::Reloader
  end

  post '/badges/:id' do
    if params[:secret_key] != secret_key
      status 403 and return
    end
    $redis.hmset params[:id],
      :github, params[:github],
      :commit_hash, params[:commit_hash],
      :updated_at, Time.now.to_i
  end

  get '/badges/:id.svg' do
    if app = fetch_app(params[:id])
      content_type "image/svg+xml"
      erb :badge, locals: app
    else
      status 404 and return
    end
  end

  get '/badges/:id' do
    if app = fetch_app(params[:id])
      body app.inspect
      redirect "https://github.com/#{app[:github]}/tree/#{app[:commit_hash]}"
    else
      status 404 and return
    end
  end

  private

    def secret_key
      ENV.fetch("SECRET_KEY")
    end

    def fetch_app(id)
      result = $redis.hmget params[:id], :github, :commit_hash, :updated_at
      return if result.compact.empty?
      [:github, :commit_hash, :updated_at].zip(result).to_h
    end

end
