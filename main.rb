require 'sinatra'
require './lib/config'
require './lib/pocket/api'
require './lib/pocket/parser'
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

set :static_cache_control, [:public, max_age: 300]

get '/' do
  send_file File.expand_path('index.html', settings.public_dir)
end

get '/status' do
  downloader.storage_driver.save('status', 'yes')
  if downloader.storage_driver.read('status') == 'yes'
    status 200
  else
    status 500
  end
end

get '/export/:status/:data_method' do
  puts 'Retrieving auth token...'
  status = params[:status]
  data_method = params[:data_method]
  request_token = pocket_api.read_request_token

  if request_token.empty?
    [400, 'Error Reading Request Token']
  else
    auth_url = "https://getpocket.com/auth/authorize?request_token=#{request_token}&redirect_uri=#{config.server_url}/auth/#{status}/#{request_token}/#{data_method}/"
    redirect auth_url
  end
end

get '/auth/:status/:request_token/:data_method/' do
  puts 'Retrieving access token...'
  status = params[:status]
  request_token = params[:request_token]
  url_suffix = params[:data_method]
  access_token_info = downloader.read_access_token(request_token)

  if access_token_info[:error]
    [400, { msg: access_token_info[:message] }.to_json]
  else
    access_token = access_token_info[:access_token]
    log_access_token_value = access_token
    log_access_token_value = '*************' unless config.debug_enabled
    puts "Access Token: #{log_access_token_value}"

    url_id = downloader.save_data(access_token)

    redirect "/data/#{url_id}/#{status}/#{url_suffix}"
  end
end

get '/data/:id/:status_ignored/data.json' do
  content_type 'application/json'
  article_data_json = downloader.read_data params[:id]

  if article_data_json.empty?
    status 404
  else
    article_data_json
  end
end

get '/data/:id/:status/list_by_tag.json' do
  content_type 'application/json'
  article_data_json = downloader.read_data params[:id]

  if article_data_json.empty?
    status 404
  else
    articles = Pocket::Parser.articles(article_data_json, params[:status])
    articles_by_tag = Pocket::Parser.urls_by_tag(articles)
    articles_by_tag.to_json
  end
end

get '/data/:id/:status/list_by_tag.txt' do
  content_type 'text/plain'
  article_data_json = downloader.read_data params[:id]

  if article_data_json.empty?
    status 404
  else
    articles = Pocket::Parser.articles(article_data_json, params[:status])
    articles_by_tag = Pocket::Parser.urls_by_tag(articles)
    haml :dict_values_per_key, locals: { dict: articles_by_tag }
  end
end

get '/data/:id/:status/list.txt' do
  content_type 'text/plain'
  article_data_json = downloader.read_data params[:id]

  if article_data_json.empty?
    status 404
  else
    articles = Pocket::Parser.articles(article_data_json, params[:status])
    article_list = Pocket::Parser.urls(articles)
    haml :array_list, locals: { array: article_list }
  end
end

puts 'Webserver Ready'
puts "Open #{config.server_url} to start the export"
