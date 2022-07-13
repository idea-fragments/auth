RSpec.describe Auth::PasswordlessLoginTokenCreator do
  let(:user_id) { 9993 }

  before { Timecop.freeze }

  after { Timecop.return }

  it "Returns an expiring token for resetting a password" do
    expect(Jwt::Decoder.call(described_class.call(user_id)))
      .to include({
        action: "passwordless_login",
        dat: { id: 9993 },
        exp: TimeHelper.add_minutes(30).to_i
      })
  end
end
