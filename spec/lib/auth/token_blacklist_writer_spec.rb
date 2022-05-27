RSpec.describe Auth::TokenBlacklistWriter do
  let(:key) { Auth.blacklist_key_for_token(token) }
  let(:ttl) { 2 }
  let(:token) { Auth::Authorizer.call({})[:access_token] }

  before { Auth.access_token_ttl_minutes = ttl }

  it "Adds given token to a blacklist redis for given duration" do
    expect { Auth::TokenBlacklistWriter.call(token) }
      .to change { Auth.redis.get(key) }.from(nil).to(token)
      .and change { Auth.redis.ttl(key) }.from(-2).to(TimeHelper.minutes(ttl))
  end

  context "If the token is already expired" do
    before do
      token
      Timecop.freeze TimeHelper.add_minutes(ttl)
    end

    it "Will not blacklist the token" do
      # expect(Auth.redis).to_not receive(:set)

      Auth::TokenBlacklistWriter.call(token)
      expect(Auth.redis.get(key)).to be_nil
    end
  end
end
