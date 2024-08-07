# frozen_string_literal: true

class Auth::TokenConfirmer < Auth::Service
  def self.call(token, action:, record_finder:, callback:, skip_blacklist: false)
    new(token, action, record_finder, callback, skip_blacklist).call
  end

  def call
    ensure_token_not_blacklisted
    ensure_token_not_expired
    callback.call(record_finder.call(*claims))
    return if skip_blacklist

    blacklist_token
  end

  private

  attr_accessor :action, :callback, :record_finder, :skip_blacklist, :token

  def blacklist_token
    Auth::TokenBlacklistWriter.call(token)
  end

  def claims
    # leeway added so we can still have the signature verified,
    # but not have decoder blow up since we need the user data
    @claims ||= begin
      claims = Jwt::Decoder.call(token, exp_leeway: TimeHelper.days(365))
        .tap(&method(:ensure_valid_token_action))
        .fetch(:dat)

      [claims[:id], claims.except(:id)]
    end
  end

  def ensure_token_not_blacklisted
    raise Auth::TokenAlreadyUsedError if Auth::TokenBlacklist.contains?(token)
  end

  def ensure_token_not_expired
    ttl = Jwt::TokenTtlCalculator.call(token)
    raise Auth::TokenExpiredError.new(*claims) if ttl <= 0
  end

  def ensure_valid_token_action(claims)
    raise Auth::InvalidTokenActionError unless
      claims[:action] == action
  end

  def initialize(token, action, record_finder, callback, skip_blacklist)
    self.action = action
    self.callback = callback
    self.record_finder = record_finder
    self.skip_blacklist = skip_blacklist
    self.token = token
  end
end
