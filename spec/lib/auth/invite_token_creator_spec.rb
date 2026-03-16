RSpec.describe Auth::InviteTokenCreator do
  let(:email) { "some@mail.com" }
  let(:invite_id) { 323 }
  let(:team_id) { 12 }

  before { Timecop.freeze }

  after { Timecop.return }

  it "Returns expiring email confirmation token" do
    token = Auth::InviteTokenCreator.call(
      invite_id: invite_id, team_id: team_id, email: email
    )

    expect(Jwt::Decoder.call(token:)).to include({
      dat: { email:, invite_id:, team_id: }.merge(action: "invite"),
      exp: 7.days.from_now.to_i
    })
  end
end
