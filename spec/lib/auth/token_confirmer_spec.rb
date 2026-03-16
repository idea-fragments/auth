# frozen_string_literal: true

RSpec.describe Auth::TokenConfirmer do
  let(:action) { "some_action" }
  let(:claims) { { some: "claims" } }
  let(:expires_at) { 1.hour.from_now }
  let(:other_params) { { action: } }
  let(:returned_claims) { Auth::TokenConfirmer.call(token:, **other_params) }
  let!(:token) do
    Auth::SecurityTokenCreator.call(
      action:, claims:, expires_at:
    )
  end

  before do
    Timecop.freeze
    allow(Auth::TokenBlacklistWriter).to receive(:call)
  end

  after { Timecop.return }

  it "Confirms record and blacklists the record token" do
    expect(returned_claims).to match(claims.merge(action:))
    expect(Auth::TokenBlacklistWriter).to have_received(:call).with(token:)
  end

  context "When token is already expired" do
    before { Timecop.freeze(expires_at + 1.minute) }

    it "Raises JWT::ExpiredSignature" do
      expect { returned_claims }.to raise_error(JWT::ExpiredSignature)
    end

    context "And skip_expiration_check is set to true" do
      before { other_params.merge!(skip_expiration_check: true) }

      it "Adds a long leeway when decoding the token" do
        expect(Jwt::Decoder).to receive(:call).with(
          exp_leeway: 365.days.to_i,
          token:
        ).and_call_original

        expect { returned_claims }.to_not raise_error(JWT::ExpiredSignature)
      end
    end
  end

  context "When token is already blacklisted" do
    before do
      expect(Auth::TokenBlacklist).to receive(:contains?)
        .with(token:).and_return(true)
    end

    it "Raises error" do
      expect { returned_claims }.to raise_error(Auth::TokenAlreadyUsedError)
    end
  end

  context "When the token should not be blacklisted" do
    before { other_params.merge!(skip_blacklist: true) }

    it "Does not blacklist the token" do
      expect(returned_claims).to match(claims.merge(action:))
      expect(Auth::TokenBlacklistWriter).to_not have_received(:call)
    end
  end

  context "When expiration_leeway is provided" do
    let(:expiration_leeway) { 1.day }

    before { other_params.merge!(expiration_leeway:) }

    it "Allows decoding within the leeway window" do
      expect(Jwt::Decoder).to receive(:call).with(
        exp_leeway: expiration_leeway.to_i,
        token:
      ).and_call_original

      expect { returned_claims }.to_not raise_error(JWT::ExpiredSignature)
    end
  end

  context "When both expiration_leeway and skip_expiration_check are provided" do
    before { other_params.merge!(expiration_leeway: 60, skip_expiration_check: true) }

    it "Raises an ArgumentError" do
      expect { returned_claims }.to raise_error(
        described_class::InvalidArgumentsError,
        "Cannot provide both expiration_leeway and skip_expiration_check"
      )
    end
  end
end
