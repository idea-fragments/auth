# frozen_string_literal: true

RSpec.describe Auth::Refresher do
  let(:new_tokens) { { access_token: "new_access_token", refresh_token: "new_refresh_token" } }
  let!(:old_tokens) { Auth::Authorizer.call(user_info:) }
  let(:refreshed_tokens) { Auth::Refresher.call(user_info:, **old_tokens) }
  let(:user_info) { { id: 323, name: "John Doe" } }

  before do
    allow(Auth::Authorizer).to receive(:call).and_return(new_tokens)
    allow(Auth::TokenConfirmer).to receive(:call)
  end

  it "Calls the token verification service and returns the newly provisioned tokens" do
    expect(refreshed_tokens).to match(new_tokens)

    expect(Auth::TokenConfirmer).to have_received(:call).with(
      action: Auth::TOKEN_ACTION_AUTHENTICATION,
      skip_expiration_check: true,
      token: old_tokens.fetch(:access_token),
    )

    expect(Auth::TokenConfirmer).to have_received(:call).with(
      action: Auth::TOKEN_ACTION_AUTHENTICATION_REFRESH,
      token: old_tokens.fetch(:refresh_token),
    )

    expect(Auth::Authorizer).to have_received(:call).with(user_info:)
  end

  context "When an error occurs during token verification" do
    let(:error) { StandardError.new("Invalid token") }

    before do
      allow(Auth::TokenConfirmer).to receive(:call).and_raise(error)
    end

    it "Raises the error" do
      expect { refreshed_tokens }.to raise_error(error)
      expect(Auth::Authorizer).to_not have_received(:call)
    end
  end
end
