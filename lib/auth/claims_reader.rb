# frozen_string_literal: true

class Auth::ClaimsReader < Service
  AlreadyUsedError = Class.new(StandardError)

  class ExpiredError < StandardError
    attr_reader :token

    def initialize(token)
      super
      @token = token
    end
  end

  def self.call(token, verify_sig: true)
    new(token, verify_sig).call
  end

  def call
    ensure_token_not_blacklisted
    claims = Jwt::Decoder.call(token, verify_sig: verify_sig)
    raise Auth::InvalidClaimsError unless claims.key?(:dat)

    claims[:dat]
  end

  private

  attr_reader :token, :verify_sig

  def ensure_token_not_blacklisted
    raise AlreadyUsedError if Auth::TokenBlacklist.contains?(token)
  end

  def initialize(token, verify_sig)
    @token = token
    @verify_sig = verify_sig
  end
end
