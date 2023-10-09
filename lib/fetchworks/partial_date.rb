# frozen_string_literal: true

require "time"

# Date representation that permits nil values
# We need this because of the nature of date values for works
# Oftentimes a year is known, but a month, or day is not.
class PartialDate
  class PartialDateError < StandardError; end
  class PartialDateArgError < PartialDateError; end
  attr_accessor :year, :month, :day

  def to_date
    Date.new(year, (month || 1), (day || 1))
  end

  def to_time
    date.to_time
  end

  def <=>(other)
    to_date <=> other.to_date
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
  def initialize(arg)
    if arg.is_a? Time
      arg = arg.to_date
    end

    if arg.is_a? Date
      arg = [arg.year, arg.month, arg.day]
    end

    unless arg.is_a? Array
      raise PartialDateArgError, "Did not receive a Date, Time, or Array"
    end

    unless arg.length.between?(1, 3)
      raise PartialDateArgError, "Received array of incorrect length."
    end

    @year = arg[0]
    @month = arg[1]
    @day = arg[2]
  end
end
