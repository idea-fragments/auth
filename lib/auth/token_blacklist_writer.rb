# frozen_string_literal: true

class Auth::TokenBlacklistWriter < Auth::Service
  def self.call(token:)
    new(token:).call
  end

  def call
    ttl = Jwt::TokenTtlCalculator.call(token:)

    Auth.redis.set(
      Auth.blacklist_key_for_token(token), token, ex: ttl
    ) if ttl.positive?
  end

  private

  attr_accessor :token

  def initialize(token:)
    super()
    self.token = token
  end
end
