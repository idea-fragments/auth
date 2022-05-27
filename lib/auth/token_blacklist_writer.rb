# frozen_string_literal: true

class Auth::TokenBlacklistWriter
  def self.call(token)
    ttl = Jwt::TokenTtlCalculator.call(token)

    Auth.redis.set(
      Auth.blacklist_key_for_token(token), token, ex: ttl
    ) if ttl.positive?
  end
end
