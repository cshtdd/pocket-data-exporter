require 'httparty'

puts 'Export Pocket Articles'  

consumer_key = ENV['CONSUMER_KEY'] || ''
puts "Consumer Key: #{consumer_key}"

if consumer_key.empty?
  puts 'ERROR: Consumer Key missing'
  exit 1
end

puts 'Retrieving auth token'

token_response = HTTParty.post(
  'https://getpocket.com/v3/oauth/request',
  debug_output: STDOUT,
  headers: {
    'User-Agent': 'Pocket-Exporter',
    'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
    'X-Accept': 'application/x-www-form-urlencoded'
  },
  body: {
    consumer_key: consumer_key,
    redirect_uri: 'http://localhost:8080/auth'
  }
)

puts token_response

puts 'Export Completed'
