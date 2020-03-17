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
# pocket_api.is_debug = true
puts 'Pocket Api Initialized'

puts 'Starting web server...'

get '/' do
  puts 'Retrieving auth token...'
  request_token = pocket_api.read_request_token

  if request_token.empty?
    status 500
    body 'Error Reading Request Token'
  else
    auth_url = "https://getpocket.com/auth/authorize?request_token=#{request_token}&redirect_uri=#{config.server_url}/token/#{request_token}"
    redirect auth_url
  end
end

get '/token/:code' do
  content_type 'application/json'
  request_token = params[:code] || ''

  if request_token.empty?
    status 400
    body({ msg: 'Invalid Token' }.to_json)
  else
    puts "Auth Request Code: #{request_token}"

    access_token = pocket_api.read_access_token(request_token)

    if access_token.empty?
      status 400
      body({ msg: 'Error Reading Access Token' }.to_json)
    else
      puts 'Access Token: ***********'

      articles_json = pocket_api.read_all_articles_json(access_token)

      if articles_json.empty?
        status 400
        body({ msg: 'Error Reading Articles' }.to_json)
      end

      status 200
      body articles_json
    end
  end
end

puts 'Starting Export...'
Launchy.open(config.server_url)

