require 'httparty'
require 'json'

class Pocket
  attr_accessor :consumer_key
  attr_accessor :user_agent
  attr_accessor :debug_enabled

  def initialize(consumer_key, debug_enabled = false)
    self.debug_enabled = debug_enabled
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
    twenty_years = (20 * 365 * 24 * 60 * 60)
    twenty_years_ago = (Time.now.utc - twenty_years).to_i

    response = json_post_v3(
      'get',
      {
        consumer_key: consumer_key,
        access_token: access_token,
        # contentType: 'article',
        detailType: 'complete',
        since: twenty_years_ago
      }
    )

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
    log_debug(stream.string) if debug_enabled
  end

  def log_debug(str)
    log(str) if debug_enabled
  end

  def log(str)
    puts(str)
  end
end