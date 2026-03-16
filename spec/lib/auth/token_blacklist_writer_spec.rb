RSpec.describe Auth::TokenBlacklistWriter do
  let(:key) { Auth.blacklist_key_for_token(token) }
  let(:token) { Auth::Authorizer.call[:access_token] }
  let(:ttl) { 2 }

  before { Auth.access_token_ttl_minutes = ttl }

  it "Adds given token to a blacklist redis for given duration" do
    expect { Auth::TokenBlacklistWriter.call(token:) }
      .to change { Auth.redis.get(key) }.from(nil).to(token)
      .and change { Auth.redis.ttl(key) }.from(-2).to(ttl.minutes.to_i)
  end

  context "If the token is already expired" do
    before do
      token
      Timecop.freeze ttl.minutes.from_now
    end

    it "Will not blacklist the token" do
      expect(Auth.redis).to_not receive(:set)

      Auth::TokenBlacklistWriter.call(token:)
      expect(Auth.redis.get(key)).to be_nil
    end
  end
end
