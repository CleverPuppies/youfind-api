require 'redis'

module YouFind
    module Cache
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