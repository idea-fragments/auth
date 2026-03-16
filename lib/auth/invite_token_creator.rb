# frozen_string_literal: true

class Auth::InviteTokenCreator
  def self.call(invite_id:, **other_claims)
    new(invite_id:, other_claims:).call
  end

  def call
    Auth::SecurityTokenCreator.call(
      action: Auth::TOKEN_ACTION_INVITE,
      claims: { invite_id:, **other_claims },
      expires_at: Auth.invite_expiration
    )
  end

  private

  attr_accessor :invite_id, :other_claims

  def initialize(invite_id:, other_claims:)
    super()
    self.invite_id = invite_id
    self.other_claims = other_claims
  end
end
