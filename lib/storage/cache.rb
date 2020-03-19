require 'mini_cache'

module Storage
  class Cache
    def initialize
      @@cache = MiniCache::Store.new
    end

    def save(key, value)
      @@cache.set(key, value, expires_in: 60)
    end

    def contains(key)
      @@cache.set?(key)
    end

    def read(key)
      @@cache.get(key)
    end
  end
end