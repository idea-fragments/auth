RSpec.describe Auth::TokenBlacklist do
  let(:token) { "dsf43rdfdsaf.fdsaf43r" }
  let(:key) { Auth.blacklist_key_for_token(token) }
  let(:duration) { 100 }

  before do
    Timecop.freeze
    expect(Jwt::TokenTtlCalculator).to receive(:call).with(token)
                                                     .and_return duration
    Auth::TokenBlacklistWriter.call(token)
  end

  it "Confirms that token is in Blacklist" do
    expect(Auth::TokenBlacklist.contains?(token)).to eq true
  end

  context "When duration has passed" do
    before { Timecop.freeze(TimeHelper.add_seconds(duration + 1)) }

    after { Timecop.return }

    it "Will not blacklist token" do
      expect(Auth::TokenBlacklist.contains?(token)).to eq false
    end
  end
end
