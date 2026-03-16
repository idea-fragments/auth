RSpec.describe Auth::TokenBlacklist do
  let(:token) { "dsf43rdfdsaf.fdsaf43r" }
  let(:key) { Auth.blacklist_key_for_token(token) }
  let(:duration) { 100 }

  before do
    Timecop.freeze
    expect(Jwt::TokenTtlCalculator).to receive(:call).with(token:)
      .and_return duration
    Auth::TokenBlacklistWriter.call(token:)
  end

  it "Confirms that token is in Blacklist" do
    expect(Auth::TokenBlacklist.contains?(token:)).to be true
  end

  context "When duration has passed" do
    before { Timecop.freeze((duration + 1).seconds.from_now) }

    after { Timecop.return }

    it "Will not blacklist token" do
      expect(Auth::TokenBlacklist.contains?(token:)).to be false
    end
  end
end
