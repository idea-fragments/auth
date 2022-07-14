# frozen_string_literal: true

class Auth::InviteTokenCreator
  def self.call(invite_id, **other_claims)
    Jwt::Encoder.call({
      action: Auth::TOKEN_ACTION_INVITE,
      exp: Auth.invite_expiration.to_i,
      dat: { id: invite_id, **other_claims }
    })
  end
end
