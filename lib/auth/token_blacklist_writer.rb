# frozen_string_literal: true

class Auth::TokenBlacklistWriter
  def self.call(token, duration)
    Auth.redis.set(
      Auth.blacklist_key_for_token(token),
      token,
      ex: duration
    )
  end
end
