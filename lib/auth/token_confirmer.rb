# frozen_string_literal: true

class Auth::TokenConfirmer < Auth::Service
  class InvalidArgumentsError < StandardError; end

  def self.call(
    action:,
    expiration_leeway: nil,
    skip_blacklist: false,
    skip_expiration_check: false,
    token:
  )
    new(
      action:,
      expiration_leeway:,
      skip_blacklist:,
      skip_expiration_check:,
      token:
    ).call
  end

  def call
    ensure_valid_expiration_params
    ensure_token_not_blacklisted

    decode_token
    ensure_valid_token_action
    blacklist_token
    claims
  end

  private

  attr_accessor :action,
    :claims,
    :expiration_leeway,
    :skip_blacklist,
    :skip_expiration_check,
    :token

  def blacklist_token
    return if skip_blacklist
    Auth::TokenBlacklistWriter.call(token:)
  end

  def decode_token
    exp_leeway = skip_expiration_check ?
      365.days.to_i :
      (expiration_leeway || 0).to_i

    self.claims = Jwt::Decoder.call(exp_leeway:, token:)
      .fetch(:dat)
  end

  def ensure_token_not_blacklisted
    raise Auth::TokenAlreadyUsedError.new("action=#{action}") if Auth::TokenBlacklist.contains?(token:)
  end

  def ensure_valid_expiration_params
    if expiration_leeway.present? && skip_expiration_check
      raise InvalidArgumentsError.new(
        "Cannot provide both expiration_leeway and skip_expiration_check"
      )
    end
  end

  def ensure_valid_token_action
    return if claims[:action] == action
    raise Auth::InvalidTokenActionError
  end

  def initialize(action:, expiration_leeway:, skip_blacklist:, skip_expiration_check:, token:)
    super()
    self.action = action
    self.expiration_leeway = expiration_leeway
    self.skip_blacklist = skip_blacklist
    self.skip_expiration_check = skip_expiration_check
    self.token = token
  end
end
