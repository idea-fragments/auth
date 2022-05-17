# frozen_string_literal: true

class Auth::TokenConfirmer < Service
  def self.call(token, record_finder:, callback:)
    new(token, record_finder, callback).call
  end

  def call
    ensure_token_not_blacklisted
    ensure_token_not_expired
    callback.call(record_finder.call(*claims))
    blacklist_token
  end

  private

  attr_accessor :callback, :record_finder, :token

  def blacklist_token
    Auth::TokenBlacklistWriter.call(token, Jwt::TokenTtlCalculator.call(token))
  end

  def claims
    # leeway added so we can still have the signature verified,
    # but not have decoder blow up since we need the user data
    claims = Jwt::Decoder.call(token, exp_leeway: TimeHelper.days(365))[:dat]

    [claims[:id], claims.except(:id)]
  end

  def ensure_token_not_blacklisted
    raise Auth::TokenAlreadyUsedError if Auth::TokenBlacklist.contains?(token)
  end

  def ensure_token_not_expired
    ttl = Jwt::TokenTtlCalculator.call(token)
    raise Auth::TokenExpiredError if ttl <= 0
  end

  def initialize(token, record_finder, callback)
    self.callback = callback
    self.record_finder = record_finder
    self.token = token
  end
end
