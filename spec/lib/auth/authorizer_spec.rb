RSpec.describe Auth::Authorizer do
  let(:access_token_ttl_minutes) { (1..10).to_a.sample }
  let(:authorized_tokens) { Auth::Authorizer.call(user_info:) }
  let(:refresh_token_ttl_days) { (1..7).to_a.sample }
  let(:user_id) { 637 }
  let(:user_info) do
    {
      id: user_id,
      first_name: "Window",
      email: "some@mail.com",
    }
  end

  before do
    Timecop.freeze
    Auth.access_token_ttl_minutes = access_token_ttl_minutes
    Auth.refresh_token_ttl_days = refresh_token_ttl_days
  end

  after { Timecop.return }

  it "Returns expiring access and refresh tokens" do
    access_token, refresh_token = authorized_tokens.fetch_values(:access_token, :refresh_token)

    expect(Jwt::Decoder.call(token: access_token)).to include({
      dat: user_info.merge(action: "authentication"),
      exp: access_token_ttl_minutes.minutes.from_now.to_i
    })

    expect(Jwt::Decoder.call(token: refresh_token)).to include({
      dat: user_info.merge(action: "authentication_refresh"),
      exp: refresh_token_ttl_days.days.from_now.to_i
    })
  end
end
