# frozen_string_literal: true

class TimeHelper
  def self.add_days(n, start_time = Time.now)
    start_time + days(n)
  end

  def self.add_minutes(n, start_time = Time.now)
    start_time + minutes(n)
  end

  def self.add_seconds(n, start_time = Time.now)
    start_time + n
  end

  def self.days(n)
    hours(24) * n
  end

  def self.hours(n)
    minutes(60) * n
  end

  def self.minutes(n)
    60 * n
  end
end
