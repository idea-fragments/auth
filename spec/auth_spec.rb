# frozen_string_literal: true

RSpec.describe Auth do
  before { Timecop.freeze(Time.new(2022, 1, 30, 23, 0, 20)) }

  after { Timecop.return }

  it "has a version number" do
    expect(Auth::VERSION).not_to be nil
  end

  [
    [:access_token_expiration, :access_token_ttl_minutes],
    [:passwordless_login_expiration, :passwordless_login_ttl_minutes],
  ].each do |method, ttl_minutes|
    describe "##{method}" do
      it "returns the #{ttl_minutes} days from now" do
        Auth.public_send("#{ttl_minutes}=", 10)
        expect(Auth.public_send(method)).to eq(Time.new(2022, 1, 30, 23, 10, 20))
        Auth.public_send("#{ttl_minutes}=", 15)
        expect(Auth.public_send(method)).to eq(Time.new(2022, 1, 30, 23, 15, 20))
      end
    end
  end

  [
    [:email_confirmation_expiration, :email_confirmation_ttl_days],
    [:invite_expiration, :invite_ttl_days],
    [:password_reset_expiration, :password_reset_ttl_days],
    [:refresh_token_expiration, :refresh_token_ttl_days],
  ].each do |method, ttl_days|
    describe "##{method}" do
      it "returns the #{ttl_days} days from now" do
        Auth.public_send("#{ttl_days}=", 7)
        expect(Auth.public_send(method)).to eq(Time.new(2022, 2, 6, 23, 0, 20))
        Auth.public_send("#{ttl_days}=", 2)
        expect(Auth.public_send(method)).to eq(Time.new(2022, 2, 1, 23, 0, 20))
      end
    end
  end
end
