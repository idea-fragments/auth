# frozen_string_literal: true

RSpec.describe Auth do
  before { Timecop.freeze(Time.new(2022, 1, 30, 23, 0, 20)) }

  after { Timecop.return }

  it "has a version number" do
    expect(Auth::VERSION).not_to be_nil
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

  describe ".validate_configuration!" do
    it "Does not raise when all configuration is set" do
      expect { Auth.validate_configuration! }.to_not raise_error
    end

    context "When a required field is missing" do
      before { Auth.jwt_secret = nil }

      it "Raises a ConfigurationError" do
        expect { Auth.validate_configuration! }
          .to raise_error(Auth::ConfigurationError, /jwt_secret/)
      end
    end

    context "When multiple required fields are missing" do
      before do
        Auth.jwt_secret = nil
        Auth.redis = nil
      end

      it "Raises a ConfigurationError listing all missing fields" do
        expect { Auth.validate_configuration! }
          .to raise_error(Auth::ConfigurationError, /jwt_secret, redis/)
      end
    end
  end
end
