RSpec.describe Auth::TokenConfirmer do
  let(:callback) { ->(_invite) {} }
  let(:other_claims) { { other: "claims" } }
  let(:params) do
    {
      action: Auth::TOKEN_ACTION_INVITE,
      record_finder: record_finder,
      callback: callback
    }
  end
  let(:record) { double(id: 323) }
  let(:record_finder) { ->(_id, _claims) { record } }
  let(:token) { Auth::InviteTokenCreator.call(record.id, **other_claims) }
  let(:token_ttl) { 444 }

  let(:confirm_token) { Auth::TokenConfirmer.call(token, **params) }

  it "Confirms record and blacklists the record token" do
    Timecop.freeze

    expect(Jwt::TokenTtlCalculator).to receive(:call)
      .with(token).and_return(token_ttl)

    expect(Auth::TokenBlacklistWriter).to receive(:call)
      .with(token)

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
      expect { confirm_token }.to raise_error(Auth::TokenExpiredError) do |error|
        expect(error.record_id).to eq record.id
      end
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

  context "If the token shouldn't be blacklisted" do
    before { params.merge!(skip_blacklist: true) }

    it "Will not blacklist the token" do
      Timecop.freeze
      expect(Auth::TokenBlacklistWriter).to_not receive(:call)
      confirm_token
    end
  end
end
