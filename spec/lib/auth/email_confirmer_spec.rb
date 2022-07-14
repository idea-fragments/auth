RSpec.describe Auth::EmailConfirmer do
  let(:user) { double(id: 323, email: "some@meila.com", email_confirmed?: false) }
  let(:user_finder) { ->(_id, _claims) { user } }
  let(:callback) { ->(_user) { user } }
  let(:token) { Auth::EmailTokenCreator.call(user.id, user.email) }

  let(:confirm_email) do
    Auth::EmailConfirmer.call(
      token, user_finder: user_finder, callback: callback
    )
  end

  it "Calls service to confirm the token's validity" do
    expect(Auth::TokenConfirmer).to receive(:call).with(
      token,
      action: "email_confirmation",
      record_finder: user_finder,
      callback: callback
    )
    confirm_email
  end

  context "If user's email is already confirmed" do
    before do
      expect(Auth::TokenBlacklist).to receive(:contains?)
        .with(token).and_return(false)
    end

    it "raises error" do
      allow(user).to receive(:email_confirmed?).and_return true

      expect { confirm_email }
        .to raise_error(Auth::TokenAlreadyUsedError)
    end
  end
end
