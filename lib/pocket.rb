require 'httparty'
require 'json'

class Pocket
  attr_accessor :consumer_key
  attr_accessor :user_agent
  attr_accessor :is_debug

  def initialize(consumer_key)
    self.is_debug = false
    self.user_agent = 'Pocket-Exporter'
    self.consumer_key = consumer_key
  end

  def read_request_token(redirect_url = 'EMPTY')
    debug_log = StringIO.new

    response = HTTParty.post(
      'https://getpocket.com/v3/oauth/request',
      debug_output: debug_log,
      headers: json_request_headers,
      body: {
        consumer_key: consumer_key,
        redirect_uri: redirect_url
      }.to_json
    )

    if response.code != 200
      ''
    else
      JSON.parse(response.body)['code']
    end
  ensure
    log_buffer(debug_log)
  end

  def read_access_token(request_token)
    debug_log = StringIO.new

    response = HTTParty.post(
      'https://getpocket.com/v3/oauth/authorize',
      debug_output: debug_log,
      headers: json_request_headers,
      body: {
        consumer_key: consumer_key,
        code: request_token
      }.to_json
    )

    if response.code != 200
      ''
    else
      JSON.parse(response.body)['access_token']
    end
  ensure
    log_buffer(debug_log)
  end

  private

  def json_request_headers
    {
      'User-Agent': user_agent,
      'Content-Type': 'application/json; charset=UTF-8',
      'X-Accept': 'application/json'
    }
  end

  def log_buffer(stream)
    log(stream.string) if is_debug
  end

  def log(str)
    puts(str) if is_debug
  end
end