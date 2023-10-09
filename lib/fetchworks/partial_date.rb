# frozen_string_literal: true

require "time"

# Date representation that permits nil values
# We need this because of the nature of date values for works
# Oftentimes a year is known, but a month, or day is not.
class PartialDate
  class PartialDateError < StandardError; end
  class PartialDateArgError < PartialDateError; end
  attr_accessor :year, :month, :day

  def date
    Date.new(year, (month || 1), (day || 1))
  end

  def time
    date.to_time
  end

  def ==(other)
    self.class == other.class &&
      @year == other.year &&
      @month == other.month &&
      @day == other.day
  end

  # We accept three formats, Date, Time (which we drop down to a Date),
  # and an array of up three integers in the format: [year, month, day]
  # TODO: Validate array input
  def initialize(date)
    if date.is_a? Time
      date = date.to_date
    end

    if date.is_a? Date
      date = [date.year, date.month, date.day]
    end

    unless date.is_a? Array
      raise PartialDateArgError, "Did not receive a Date, Time, or Array"
    end

    unless date.length.between?(1, 3)
      raise PartialDateArgError, "Received array of incorrect length."
    end

    @year = date[0]
    @month = date[1]
    @day = date[2]
  end
end
