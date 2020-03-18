class Downloader
  attr_accessor :pocket_api_client
  attr_accessor :debug_enabled

  def initialize(pocket_api_client, debug_enabled = false)
    self.pocket_api_client = pocket_api_client
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

  private

  def debug(msg)
    log(msg) if debug_enabled
  end

  def log(msg)
    puts msg
  end
end