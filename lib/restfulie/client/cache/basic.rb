# Basic cache implementation for restfulie.
#
# It uses the request headers and uri to store it in memory.
# This cache might not be optimal for long running clients, which should use a memcached based one.
# Use Restfulie::Client.cache_provider to change the provider
module Restfulie::Client::Cache
  class Basic

    def put(key, req, response)
      if Restfulie::Client::Cache::Restrictions.may_cache?(response)
        Restfulie::Common::Logger.logger.debug "caching #{key} #{response}"
        cache_add(key, req, response)
      end
      response
    end

    def get(key, request)

      response = cache_get(key, request)
      return nil if response.nil?

      if response.has_expired_cache?
        remove(key)
      else
        Restfulie::Common::Logger.logger.debug "RETURNING cache #{key}"
        cache_hit response
      end

    end
    
    # removes all elements from the cache
    def clear
      cache.clear
    end

  protected
  
    # allows you to redefine the cache store
    def cache
      Restfulie::Client.cache_store
    end

  private

    # allows response enhancement when the cache was hit with it
    def cache_hit(response)
      response
    end

    def cache_add(key, req, response)
      values = (cache.read(key) || []).dup
      values << [req, response]
      cache.write(key, values)
    end

    def cache_get(key, req)
      return nil unless cache.exist?(key)
      found = cache.read(key).find do |cached|
        old_req = cached.first
        old_response = cached.last
        
        headers_match = old_response.vary_headers_for(old_req) == old_response.vary_headers_for(req)
        if headers_match && old_response.verb == req.verb
          old_response
        else
          false
        end
      end
      found ? found.last : nil
    end

    def remove(key)
      cache.delete(key)
      nil
    end

  end
end
