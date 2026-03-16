# frozen_string_literal: true

class Auth::SecurityTokenCreator < Auth::Service
  def self.call(action:, claims:, expires_at:)
    new(action:, claims:, expires_at:).call
  end

  def call
    Jwt::Encoder.call(
      payload: {
        dat: claims.merge(action:),
        exp: expires_at.to_i,
      }
    )
  end

  private

  attr_accessor :action, :claims, :expires_at

  def initialize(action:, claims:, expires_at:)
    super()
    self.action = action
    self.claims = claims
    self.expires_at = expires_at
  end
end
