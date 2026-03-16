RSpec.describe Auth::EmailTokenCreator do
  let(:email) { "some@email.com" }
  let(:id) { 9993 }

  before { Timecop.freeze }

  after { Timecop.return }

  it "Returns expiring email confirmation token" do
    expect(Jwt::Decoder.call(token: described_class.call(email: email, user_id: id)))
      .to include({
        dat: { email:, user_id: id }.merge(action: "email_confirmation"),
        exp: 2.days.from_now.to_i
      })
  end
end
