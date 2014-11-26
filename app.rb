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
    Dir[File.expand_path('../lib/*.rb',  __FILE__)].each { |f| also_reload f }
  end

  post '/badges/:secret_key/:id' do
    STDERR.puts params.inspect
    if params[:secret_key] != secret_key
      body "Forbidden"
      status 403
      return
    end
    if resource = Resource.find(params[:id])
      resource.assign_attributes(params)
    else
      resource = Resource.new(id: params[:id])
      resource.assign_attributes(params)
    end
    unless resource.save
      body "Dunno"
      status 401
      return
    end
    content_type 'application/json'
    # body resource.inspect
    body JSON.generate(resource.attributes)
  end

  get '/badges/:id.svg' do
    if resource = Resource.find(params[:id])
      content_type "image/svg+xml"
      erb :badge, locals: { resource: resource }
    else
      body "Not found"
      status 404
    end
  end

  get '/badges/:id/github' do
    if resource = Resource.find(params[:id])
      redirect "https://github.com/#{resource[:github]}/tree/#{resource[:head_long]}"
    else
      body "Not found"
      status 404
    end
  end

  get '/badges/:id' do
    if resource = Resource.find(params[:id])
      haml :badge, locals: { resource: resource }
    else
      body "Not found"
      status 404
    end
  end

  private

    def secret_key
      ENV.fetch("SECRET_KEY")
    end

end
