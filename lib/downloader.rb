class Downloader
  attr_accessor :pocket_api_client
  attr_accessor :debug_enabled

  def initialize(pocket_api_client, debug_enabled = false)
    self.pocket_api_client = pocket_api_client
    self.debug_enabled = debug_enabled
    @cache = MiniCache::Store.new
  end

  def read_access_token(request_token)
    if request_token.empty?
      return { error: true, message: 'Invalid Request Token' }
    end

    debug("Auth Request Code: #{request_token}")

    access_token = pocket_api_client.read_access_token(request_token)

    if access_token.empty?
      return { error: true, message: 'Invalid Access Token' }
    end

    debug("Access Token: #{access_token}")

    { error: false, access_token: access_token }
  end

  def save_data(access_token)
    data = pocket_api_client.read_all_articles_json(access_token)
    url_id = next_id
    save_in_cache(url_id, access_token)
    save_in_cache(access_token, url_id)
    save_in_cache(access_token, data)

    #  TODO return errors or successes
  end

  def read_data(url_id)
    # TODO finish this
  end

  private

  def next_id
    (0...8).map { ('a'..'z').to_a[rand(26)] }.join
  end

  def save_in_cache(key, value)
    @cache.set(key, value, expires_in: 60)
  end

  def cache_contains(key)
    @cache.set?(key)
  end

  def debug(msg)
    log(msg) if debug_enabled
  end

  def log(msg)
    puts msg
  end
end