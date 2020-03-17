class Config
  attr_accessor :consumer_key
  attr_accessor :server_url

  def self.read
    result = Config.new

    result.consumer_key = ENV['CONSUMER_KEY'] || ''
    result.server_url = ENV['SERVER_URL'] || 'http://localhost:4567'

    result
  end

  def valid?
    return false if consumer_key.empty?

    true
  end
end