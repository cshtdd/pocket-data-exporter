require 'httparty'
require 'json'
require 'launchy'
require 'sinatra'

puts 'Exporting Pocket Articles...'

consumer_key = ENV['CONSUMER_KEY'] || ''
puts "Consumer Key: #{consumer_key}"

server_url = 'http://localhost:4567'

if consumer_key.empty?
  puts 'ERROR: Consumer Key missing'
  exit 1
end

puts 'Starting web server...'

get '/token' do
  status 200
  body ''
end

get '/authCompleted' do
  puts 'Auth Completed'
  puts request.query_string
  puts request.body.string
  status 200
  body ''
end


puts 'Retrieving auth token...'

token_response = HTTParty.post(
  'https://getpocket.com/v3/oauth/request',
  debug_output: STDOUT,
  headers: {
    'User-Agent': 'Pocket-Exporter',
    'Content-Type': 'application/json; charset=UTF-8',
    'X-Accept': 'application/json'
  },
  body: {
    consumer_key: consumer_key,
    redirect_uri: "#{server_url}/token"
  }.to_json
)

if token_response.code != 200
  puts 'ERROR: Could not get request token'
  exit 1
end

request_token = JSON.parse(token_response.body)['code']
puts "Request Token: #{request_token}"


auth_url = "https://getpocket.com/auth/authorize?request_token=#{request_token}&redirect_uri=#{server_url}/authCompleted"
Launchy.open(auth_url)



puts 'Export Completed'
