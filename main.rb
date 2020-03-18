require 'sinatra'
require './lib/config'
require './lib/pocket/api'
require './lib/pocket/parser'
require './lib/pocket/formatter'
require './lib/downloader'

puts 'Initializing...'

config = Config.read
unless config.valid?
  puts 'ERROR: Consumer Key missing'
  exit 1
end
puts 'Configuration Read'

pocket_api = Pocket::Api.new(config.consumer_key, config.debug_enabled)
downloader = Downloader.new(pocket_api, config.debug_enabled)
puts 'Pocket Api Initialized'

puts 'Starting web server...'

get '/' do
  send_file File.expand_path('index.html', settings.public_dir)
end

get '/export/:out_method' do
  puts 'Retrieving auth token...'
  out_method = params[:out_method] || ''
  request_token = pocket_api.read_request_token

  if request_token.empty?
    status 500
    body 'Error Reading Request Token'
  else
    auth_url = "https://getpocket.com/auth/authorize?request_token=#{request_token}&redirect_uri=#{config.server_url}/#{out_method}/#{request_token}"
    redirect auth_url
  end
end

get '/raw_data_json/:code' do
  content_type 'data:application/json'
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
      log_access_token_value = access_token
      log_access_token_value = '*************' unless config.debug_enabled
      puts "Access Token: #{log_access_token_value}"

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

get '/list_by_tags_json/:code' do
  request_token = params[:code] || ''
  access_token_info = downloader.read_access_token(request_token)

  if access_token_info[:error]
    content_type 'application/json'
    [400, { msg: access_token_info[:message] }.to_json]
  else
    access_token = access_token_info[:access_token]
    log_access_token_value = access_token
    log_access_token_value = '*************' unless config.debug_enabled
    puts "Access Token: #{log_access_token_value}"

    articles_json = pocket_api.read_all_articles_json(access_token)

    if articles_json.empty?
      content_type 'application/json'
      [400, { msg: 'Error Reading Articles' }.to_json]
    end

    articles_by_tag = Pocket::Parser.articles_by_tag(articles_json)

    content_type 'data:application/json'
    body articles_by_tag.to_json
  end
end

get '/list_by_tags/:code' do
  request_token = params[:code] || ''
  access_token_info = downloader.read_access_token(request_token)

  if access_token_info[:error]
    content_type 'text/plain'
    [400, access_token_info[:message]]
  else
    access_token = access_token_info[:access_token]
    log_access_token_value = access_token
    log_access_token_value = '*************' unless config.debug_enabled
    puts "Access Token: #{log_access_token_value}"

    articles_json = pocket_api.read_all_articles_json(access_token)

    if articles_json.empty?
      content_type 'text/plain'
      [400, 'Error Reading Articles']
    end

    articles_by_tag = Pocket::Parser.articles_by_tag(articles_json)
    response_body = ''
    response_body << Pocket::Formatter.unique_dict_values_plaintext(articles_by_tag)
    response_body << "\r\n"
    response_body << Pocket::Formatter.dict_to_plaintext(articles_by_tag)

    content_type 'data:text/plain'
    response_body
  end
end

puts 'Webserver Ready'
puts "Open #{config.server_url} to start the export"
