require 'sinatra'
require 'redis'
require 'uri'

set :bind, '192.168.33.10'
redis = Redis.new

helpers do
  include Rack::Utils
  alias_method :h, :escape_html

  def random_string(length)
    rand(36**length).to_s(36)
  end

  def valid_url?(url)
    uri = URI.parse(url)
    %w( http https).include?(uri.scheme)
  rescue URI::BadURIError
    false
  rescue URI::InvalidURIError
    false
  end

end

get '/' do
  erb :index
end

post '/' do
  unless params[:url].empty?
    if valid_url?(params[:url])
      @shortcode = random_string 5
      redis.setnx "links:#{@shortcode}", params[:url]
    end
  end
  erb :index
end

get '/:shortcode' do
  @url = redis.get "links:#{params[:shortcode]}"
  redirect @url || '/'
end
