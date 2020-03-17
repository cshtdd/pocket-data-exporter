require 'launchy'
require 'sinatra'
require './lib/pocket'

puts 'Initializing...'

consumer_key = ENV['CONSUMER_KEY'] || ''
puts "Consumer Key: #{consumer_key}"

server_url = 'http://localhost:4567'

if consumer_key.empty?
  puts 'ERROR: Consumer Key missing'
  exit 1
end

pocket_api = Pocket.new(consumer_key)
pocket_api.is_debug = true

puts 'Starting web server...'

get '/' do
  puts 'Retrieving auth token...'
  redirect_url = "#{server_url}/token"
  request_token = pocket_api.read_request_token(redirect_url)

  if request_token.empty?
    status 500
    body 'Error Reading Request Token'
  else
    auth_url = "https://getpocket.com/auth/authorize?request_token=#{request_token}&redirect_uri=#{server_url}/token/#{request_token}"
    redirect auth_url
  end
end

get '/token/:code' do
  # puts 'Auth Completed'
  # puts request.query_string
  # puts request.body.string
  code = params[:code] || ''

  puts "Auth Request Code: #{code}"

  status 200
  body ''
end

puts 'Starting Export...'
Launchy.open(server_url)

