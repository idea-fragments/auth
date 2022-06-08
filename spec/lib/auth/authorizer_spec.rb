RSpec.describe Auth::Authorizer do
  let(:user_id) { 637 }
  let(:user) do
    {
      id: user_id,
      first_name: "Window",
      email: "some@mail.com",
    }
  end

  before { Timecop.freeze }

  after { Timecop.return }

  it "Returns expiring access and refresh tokens" do
    tokens = Auth::Authorizer.call(user)
    access_token = tokens[:access_token]
    refresh_token = tokens[:refresh_token]

    expect(Jwt::Decoder.call(access_token)).to include({
      dat: {
        id: user[:id],
        first_name: user[:first_name],
        email: user[:email],
      },
      exp: TimeHelper.add_minutes(10).to_i
    })

    expect(Jwt::Decoder.call(refresh_token)).to include({
      dat: {
        id: user[:id],
        first_name: user[:first_name],
        email: user[:email],
      },
      exp: TimeHelper.add_days(7).to_i
    })
  end

  context "If extra claims are needed in access token" do
    let(:team_id) { 2 }
    let(:other_claim) { "other_claim" }

    before do
      user[:team_id] = team_id
      user[:other_claim] = other_claim
    end

    it "Will add the extra claims to the token" do
      tokens = Auth::Authorizer.call(user)
      access_token = tokens[:access_token]

      expect(Jwt::Decoder.call(access_token)).to include({
        dat: {
          id: user[:id],
          first_name: user[:first_name],
          email: user[:email],
          other_claim: other_claim,
          team_id: team_id,
        },
      })
    end
  end
end
