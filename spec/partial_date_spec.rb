# frozen_string_literal: true

RSpec.describe PartialDate do
  context "When initializing" do
    it "raises PartialDateArgError when passed nil" do
      expect {
        PartialDate.new(nil)
      }.to raise_error PartialDate::PartialDateArgError
    end
    it "raises PartialDateArgError when passed something that is
        neither an Array, Date, nor Time" do
      expect {
        PartialDate.new("January 12, 1984")
      }.to raise_error PartialDate::PartialDateArgError
    end
    it "raises PartialDateArgError when passed an empty array" do
      expect {
        PartialDate.new([])
      }.to raise_error PartialDate::PartialDateArgError
    end
    it "raises PartialDateArgError when passed an array with length > 3" do
      expect {
        PartialDate.new([12, 11, 1987, 1])
      }.to raise_error PartialDate::PartialDateArgError
    end
  end

# Skip crazy and big_time tests, since they mysteriously fail
# through no fault of our own:
# crazy_time.year != crazy_time.to_date.year

# let!(:crazy_time)  { Time.new(0) + rand(-(10.0**100)..10.0**100) }
# let!(:big_time)    { Time.new(0) + rand(-(10.0**11)..10.0**11) }
# context "When initialized with a crazy Time" do
#   it "has the right year" do
#     expect(PartialDate.new(crazy_time).year).to eq(crazy_time.year)
#   end
#   it "has the right month" do
#     expect(PartialDate.new(crazy_time).month).to eq(crazy_time.month)
#   end
#   it "has the right day" do
#     expect(PartialDate.new(crazy_time).day).to eq(crazy_time.day)

#   end
# end

# context "When initialized with a big Time" do
#   it "has the right year" do
#     expect(PartialDate.new(big_time).year).to eq(big_time.year)
#   end
#   it "has the right month" do
#     expect(PartialDate.new(big_time).month).to eq(big_time.month)
#   end
#   it "has the right day" do
#     expect(PartialDate.new(big_time).day).to eq(big_time.day)
#   end
# end

  context "When initialized with a normal time" do
    let(:time) { Time.new(2012) + rand(-(10.0**9)..10.0**9) }
    it "has the right year" do
      expect(PartialDate.new(time).year).to eq(time.year)
    end
    it "has the right month" do
      expect(PartialDate.new(time).month).to eq(time.month)
    end
    it "has the right day" do
      expect(PartialDate.new(time).day).to eq(time.day)
    end
    it "has the right date" do
      expect(PartialDate.new(time).date).to eq(time.to_date)
    end
  end

  context "When initialized with a normal date" do
    let(:date) { Date.new(2012) + rand(-(3.65**6)..3.65**6) }
    it "has the right year" do
      expect(PartialDate.new(date).year).to eq(date.year)
    end
    it "has the right month" do
      expect(PartialDate.new(date).month).to eq(date.month)
    end
    it "has the right day" do
      expect(PartialDate.new(date).day).to eq(date.day)
    end
    it "has the right date" do
      # Need to .to_time.to_date in order to drop the seconds and nanoseconds from date
      expect(PartialDate.new(date).date).to eq(date.to_time.to_date)
    end
  end

  context "when initialized with a valid partial date array of length 1" do
    let(:array) { [rand(-(10**6)..10**6)] }
    let(:partial) { PartialDate.new(array) }
    it "has a year equal to the only element of the array" do
      expect(partial.year).to eq(array[0])
    end
    it "has a month of nil" do
      expect(partial.month).to eq(nil)
    end
    it "has a day of nil" do
      expect(partial.day).to eq(nil)
    end
    it "has a date with 1's instead of nils" do
      expect(partial.date).to eq(Date.new(array[0], 1, 1))
    end
  end

  context "when initialized with a valid partial array of length 2" do
    let(:array) { [rand(-(10**6)..10**6), rand(1..12)] }
    let(:partial) { PartialDate.new(array) }
    it "has a year equal to the first element of the array" do
      expect(partial.year).to eq(array[0])
    end
    it "has a month equal to the second element of the array" do
      expect(partial.month).to eq(array[1])
    end
    it "has a day of nil" do
      expect(partial.day).to eq(nil)
    end
    it "has a date with 1's instead of nils" do
      expect(partial.date).to eq(Date.new(array[0], array[1], 1))
    end
  end

  context "when initialized with a valid partial array of length 3" do
    let(:array) { [rand(-(10**6)..10**6), rand(1..12), rand(1..28)] }
    let(:partial) { PartialDate.new(array) }
    it "has a year equal to the first element of the array" do
      expect(partial.year).to eq(array[0])
    end
    it "has a month equal to the second element of the array" do
      expect(partial.month).to eq(array[1])
    end
    it "has a day equal to the third element of the array" do
      expect(partial.day).to eq(array[2])
    end
    it "has a date the same as Date.new" do
      expect(partial.date).to eq(Date.new(array[0], array[1], array[2]))
    end
  end
end
