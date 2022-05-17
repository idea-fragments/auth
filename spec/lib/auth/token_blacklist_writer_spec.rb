RSpec.describe Auth::TokenBlacklistWriter do
  let(:token) { "dsf43rdfdsaf.fdsaf43r" }
  let(:key) { Auth.blacklist_key_for_token(token) }

  it "Adds given token to a blacklist redis for given duration" do
    duration = 434

    expect { Auth::TokenBlacklistWriter.call(token, duration) }
      .to change { Auth.redis.get(key) }.from(nil).to(token)
                                        .and change { Auth.redis.ttl(key) }.from(-2).to(duration)
  end
end
