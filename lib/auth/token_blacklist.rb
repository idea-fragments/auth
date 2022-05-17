# frozen_string_literal: true

class Auth::TokenBlacklist
  def self.contains?(token)
    !Auth.redis.get(Auth.blacklist_key_for_token(token)).nil?
  end
end
