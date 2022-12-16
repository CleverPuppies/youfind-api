# frozen_string_literal: true

require 'redis'

module YouFind
  # Redis client utility
  module Cache
    # Redis client class
    class Client
      def initialize(config)
        @redis = Redis.new(url: config.REDISCLOUD_URL)
      end

      def keys
        @redis.keys
      end

      def wipe
        keys.each { |key| @redis.del(key) }
      end
    end
  end
end
