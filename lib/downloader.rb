class Downloader
  attr_accessor :pocket_api_client
  attr_accessor :storage_driver
  attr_accessor :debug_enabled

  def initialize(pocket_api_client, storage_driver, debug_enabled = false)
    self.pocket_api_client = pocket_api_client
    self.storage_driver = storage_driver
    self.debug_enabled = debug_enabled
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
    storage_driver.save(url_id, access_token)
    storage_driver.save(access_token, data)

    url_id
  end

  def read_data(url_id)
    return '' unless storage_driver.contains(url_id)

    access_token = storage_driver.read(url_id) || ''
    return '' if access_token.empty?

    return '' unless storage_driver.contains(access_token)

    storage_driver.read(access_token) || ''
  end

  private

  def next_id
    (0...8).map { ('a'..'z').to_a[rand(26)] }.join
  end

  def debug(msg)
    log(msg) if debug_enabled
  end

  def log(msg)
    puts msg
  end
end