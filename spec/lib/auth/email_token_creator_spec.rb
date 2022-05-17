RSpec.describe Auth::EmailTokenCreator do
  let(:user) { double("User", id: 9993, email: "some@email.com") }

  before { Timecop.freeze }

  after { Timecop.return }

  it "Returns expiring email confirmation token" do
    expect(Jwt::Decoder.call(Auth::EmailTokenCreator.call(user)))
      .to include({
        dat: {
          id: 9993,
          email: user.email,
        },
        exp: TimeHelper.add_days(2).to_i
      })
  end
end
