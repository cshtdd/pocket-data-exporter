require 'sinatra'
require './lib/config'
require './lib/pocket/api'
require './lib/pocket/parser'
require './lib/pocket/formatter'
require './lib/downloader'
require './lib/storage/cache'

puts 'Initializing...'

config = Config.read
unless config.valid?
  puts 'ERROR: Consumer Key missing'
  exit 1
end
puts 'Configuration Read'

pocket_api = Pocket::Api.new(config.consumer_key, config.debug_enabled)
in_memory_cache = Storage::Cache.new
downloader = Downloader.new(pocket_api, in_memory_cache, config.debug_enabled)
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
    [400, 'Error Reading Request Token']
  else
    auth_url = "https://getpocket.com/auth/authorize?request_token=#{request_token}&redirect_uri=#{config.server_url}/download/#{request_token}/#{out_method}/"
    redirect auth_url
  end
end

get '/download/:request_token/:out_method/' do
  request_token = params[:request_token] || ''
  url_suffix = params[:out_method] || ''
  access_token_info = downloader.read_access_token(request_token)

  if access_token_info[:error]
    [400, { msg: access_token_info[:message] }.to_json]
  else
    access_token = access_token_info[:access_token]
    log_access_token_value = access_token
    log_access_token_value = '*************' unless config.debug_enabled
    puts "Access Token: #{log_access_token_value}"

    url_id = downloader.save_data(access_token)

    redirect "/data/#{url_id}/#{url_suffix}"
  end
end

get '/data/:url_id/data.json' do
  content_type 'application/json'
  article_data_json = downloader.read_data(params[:url_id] || '')

  if article_data_json.empty?
    status 404
  else
    article_data_json
  end
end

get '/data/:url_id/list_by_tag.json' do
  content_type 'application/json'
  article_data_json = downloader.read_data(params[:url_id] || '')

  if article_data_json.empty?
    status 404
  else
    articles_by_tag = Pocket::Parser.articles_by_tag(article_data_json)
    articles_by_tag.to_json
  end
end

get '/data/:url_id/list_by_tag.txt' do
  content_type 'text/plain'
  article_data_json = downloader.read_data(params[:url_id] || '')

  if article_data_json.empty?
    status 404
  else
    articles_by_tag = Pocket::Parser.articles_by_tag(article_data_json)
    response_body = ''
    response_body << Pocket::Formatter.unique_dict_values_plaintext(articles_by_tag)
    response_body << "\r\n"
    response_body << Pocket::Formatter.dict_to_plaintext(articles_by_tag)
    response_body
  end
end

puts 'Webserver Ready'
puts "Open #{config.server_url} to start the export"
