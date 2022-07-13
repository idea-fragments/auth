RSpec.describe Auth::EmailTokenCreator do
  let(:email) { "some@email.com" }
  let(:id) { 9993 }

  before { Timecop.freeze }

  after { Timecop.return }

  it "Returns expiring email confirmation token" do
    expect(Jwt::Decoder.call(described_class.call(id, email)))
      .to include({
        action: "email_confirmation",
        dat: { id: id, email: email },
        exp: TimeHelper.add_days(2).to_i
      })
  end
end
