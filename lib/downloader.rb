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
    url_id = next_id

    data = pocket_api_client.read_all_articles_json(access_token)
    save_in_storage(url_id, access_token)
    save_in_storage(access_token, data)

    url_id
  end

  def read_data(url_id)
    return '' unless storage_contains(url_id)

    access_token = read_from_storage(url_id) || ''
    return '' if access_token.empty?

    return '' unless storage_contains(access_token)

    read_from_storage(access_token) || ''
  end

  private

  def next_id
    (0...8).map { ('a'..'z').to_a[rand(26)] }.join
  end

  def save_in_storage(key, value)
    @cache.set(key, value, expires_in: 60)
  end

  def storage_contains(key)
    @cache.set?(key)
  end

  def read_from_storage(key)
    @cache.get(key)
  end

  def debug(msg)
    log(msg) if debug_enabled
  end

  def log(msg)
    puts msg
  end
end