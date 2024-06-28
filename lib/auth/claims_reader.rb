# frozen_string_literal: true

class Auth::ClaimsReader < Auth::Service
  class ExpiredError < StandardError
    attr_reader :token

    def initialize(token)
      super
      @token = token
    end
  end

  def self.call(token, expiration_leeway: 0, verify_sig: true)
    new(token, expiration_leeway, verify_sig).call
  end

  def call
    ensure_token_not_blacklisted
    Jwt::Decoder.call(token, exp_leeway: expiration_leeway, verify_sig: verify_sig)
      .tap(&method(:ensure_valid_token_action))
      .tap(&method(:ensure_data_present))
      .fetch(:dat)
  end

  private

  attr_accessor :expiration_leeway, :token, :verify_sig

  def ensure_data_present(claims)
    raise Auth::InvalidClaimsError unless claims.key?(:dat)
  end

  def ensure_token_not_blacklisted
    raise Auth::TokenAlreadyUsedError if Auth::TokenBlacklist.contains?(token)
  end

  def ensure_valid_token_action(claims)
    raise Auth::InvalidTokenActionError unless
      claims[:action] == Auth::TOKEN_ACTION_AUTHENTICATION
  end

  def initialize(token, expiration_leeway, verify_sig)
    self.expiration_leeway = expiration_leeway
    self.token = token
    self.verify_sig = verify_sig
  end
end
