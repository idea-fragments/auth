RSpec.describe Auth::EmailConfirmer do
  let(:user_finder) { ->(**_args) { { email_confirmed: false } } }
  let(:token) { Auth::EmailTokenCreator.call(email: "some@meila.com", user_id: 323) }

  let(:confirm_email) do
    Auth::EmailConfirmer.call(
      token:, user_finder:
    )
  end

  it "Calls service to confirm the token's validity" do
    expect(Auth::TokenConfirmer).to receive(:call).with(
      action: "email_confirmation",
      token:
    ).and_call_original

    confirm_email
  end

  it "Provides the decoded claims to the user_finder" do
    received_claims = nil
    finder = ->(claims:) do
      received_claims = claims
      { email_confirmed: false }
    end

    Auth::EmailConfirmer.call(token:, user_finder: finder)

    expect(received_claims).to include(
      action: "email_confirmation",
      email: "some@meila.com",
      user_id: 323
    )
  end

  context "If user's email is already confirmed" do
    before do
      expect(Auth::TokenBlacklist).to receive(:contains?)
        .with(token:).and_return(false)
    end

    it "raises error" do
      confirmed_finder = ->(**_args) { { email_confirmed: true } }

      expect do
        Auth::EmailConfirmer.call(token: token, user_finder: confirmed_finder)
      end.to raise_error(Auth::UserEmailAlreadyConfirmedError)
    end
  end
end
