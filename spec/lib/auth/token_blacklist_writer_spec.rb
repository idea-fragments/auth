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
end
