# frozen_string_literal: true

class Auth::InviteTokenCreator
  def self.call(invite_id, **other_claims)
    Jwt::Encoder.call({
      exp: Auth.invite_expiration.to_i,
      dat: { id: invite_id, **other_claims }
    })
  end
end
