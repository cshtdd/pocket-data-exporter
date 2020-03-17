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
    response = json_post_v3('oauth/request',
                            { consumer_key: consumer_key, redirect_uri: redirect_url })
    if response.code != 200
      ''
    else
      JSON.parse(response.body)['code']
    end
  end

  def read_access_token(request_token)
    response = json_post_v3('oauth/authorize',
                            { consumer_key: consumer_key, code: request_token })
    if response.code != 200
      ''
    else
      JSON.parse(response.body)['access_token']
    end
  end

  def read_all_articles_json(access_token)
    response = json_post_v3(
      'get',
      {
        consumer_key: consumer_key,
        access_token: access_token,
        contentType: 'article',
        detailType: 'simple'
      })

    if response.code != 200
      ''
    else
      response.body
    end
  end

  private

  def json_post_v3(path, body)
    debug_log = StringIO.new

    url = "https://getpocket.com/v3/#{path}"

    HTTParty.post(
      url,
      debug_output: debug_log,
      headers: json_request_headers,
      body: body.to_json
    )
  ensure
    log_debug_buffer(debug_log)
  end

  def json_request_headers
    {
      'User-Agent': user_agent,
      'Content-Type': 'application/json; charset=UTF-8',
      'X-Accept': 'application/json'
    }
  end

  def log_debug_buffer(stream)
    log_debug(stream.string) if is_debug
  end

  def log_debug(str)
    log(str) if is_debug
  end

  def log(str)
    puts(str)
  end
end