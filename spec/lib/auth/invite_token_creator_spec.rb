RSpec.describe Auth::InviteTokenCreator do
  let(:email) { "some@mail.com" }
  let(:invite_id) { 323 }
  let(:team_id) { 12 }

  before { Timecop.freeze }

  after { Timecop.return }

  it "Returns expiring email confirmation token" do
    token = Auth::InviteTokenCreator.call(
      invite_id, team_id: team_id, email: email
    )

    expect(Jwt::Decoder.call(token)).to include({
      action: "invite",
      dat: { email: email, id: invite_id, team_id: team_id },
      exp: TimeHelper.add_days(7).to_i
    })
  end
end
