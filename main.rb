require 'httparty'
require 'json'
require 'launchy'

puts 'Exporting Pocket Articles...'

consumer_key = ENV['CONSUMER_KEY'] || ''
puts "Consumer Key: #{consumer_key}"

if consumer_key.empty?
  puts 'ERROR: Consumer Key missing'
  exit 1
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
    redirect_uri: 'http://localhost:8080/auth'
  }.to_json
)

if token_response.code != 200
  puts 'ERROR: Could not get request token'
  exit 1
end

request_token = JSON.parse(token_response.body)['code']
puts "Request Token: #{request_token}"


auth_url = "https://getpocket.com/auth/authorize?request_token=#{request_token}&redirect_uri=http://localhost:8080/authSuccess"
Launchy.open(auth_url)

puts 'Export Completed'
