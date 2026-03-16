RSpec.describe Auth::PasswordlessLoginTokenCreator do
  let!(:token) { described_class.call(user_id:) }
  let(:user_id) { 9993 }

  before { Timecop.freeze }

  after { Timecop.return }

  it "Returns an expiring token for resetting a password" do
    expect(Jwt::Decoder.call(token:))
      .to include({
        dat: { user_id: }.merge(action: "passwordless_login"),
        exp: 30.minutes.from_now.to_i
      })
  end
end
