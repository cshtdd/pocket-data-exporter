class Config
  attr_accessor :consumer_key
  attr_accessor :server_url
  attr_accessor :debug_enabled

  def self.read
    result = Config.new

    result.consumer_key = ENV['CONSUMER_KEY'] || ''
    result.server_url = ENV['SERVER_URL'] || 'http://localhost:4567'
    result.debug_enabled = (ENV['DEBUG'] || 'false').downcase == 'true'

    result
  end

  def valid?
    return false if consumer_key.empty?

    true
  end
end