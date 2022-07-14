RSpec.describe Auth::TokenConfirmer do
  let(:callback) { ->(_invite) {} }
  let(:other_claims) { { other: "claims" } }
  let(:record) { double(id: 323) }
  let(:record_finder) { ->(_id, _claims) { record } }
  let(:token) { Auth::InviteTokenCreator.call(record.id, **other_claims) }
  let(:token_ttl) { 444 }

  let(:confirm_token) do
    Auth::TokenConfirmer.call(
      token,
      action: Auth::TOKEN_ACTION_INVITE,
      record_finder: record_finder,
      callback: callback
    )
  end

  it "Confirms record and blacklists the record token" do
    Timecop.freeze

    expect(Jwt::TokenTtlCalculator).to receive(:call)
      .with(token).and_return(token_ttl).exactly(2).times

    expect(Auth::TokenBlacklistWriter).to receive(:call)
      .with(token, token_ttl)

    expect(record_finder).to receive(:call)
      .with(record.id, other_claims)
      .and_call_original

    expect(callback).to receive(:call).with(record)

    confirm_token
  end

  context "If token is already expired" do
    before do
      token
      Timecop.freeze(Auth.invite_expiration)
    end

    it "raises expiration error" do
      expect { confirm_token }.to raise_error(Auth::TokenExpiredError)
    end
  end

  context "If token is already blacklisted" do
    before do
      expect(Auth::TokenBlacklist).to receive(:contains?)
        .with(token).and_return(true)
    end

    it "raises error" do
      expect { confirm_token }.to raise_error(Auth::TokenAlreadyUsedError)
    end
  end
end
