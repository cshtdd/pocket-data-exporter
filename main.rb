require 'launchy'
require 'sinatra'
require './lib/config'
require './lib/pocket'

puts 'Initializing...'

config = Config.read
unless config.valid?
  puts 'ERROR: Consumer Key missing'
  exit 1
end
puts 'Configuration Read'

pocket_api = Pocket.new(config.consumer_key)
pocket_api.is_debug = true
puts 'Pocket Api Initialized'

puts 'Starting web server...'

get '/' do
  puts 'Retrieving auth token...'
  redirect_url = "#{config.server_url}/token"
  request_token = pocket_api.read_request_token(redirect_url)

  if request_token.empty?
    status 500
    body 'Error Reading Request Token'
  else
    auth_url = "https://getpocket.com/auth/authorize?request_token=#{request_token}&redirect_uri=#{config.server_url}/token/#{request_token}"
    redirect auth_url
  end
end

get '/token/:code' do
  code = params[:code] || ''

  puts "Auth Request Code: #{code}"

  status 200
  body ''
end

puts 'Starting Export...'
Launchy.open(config.server_url)

