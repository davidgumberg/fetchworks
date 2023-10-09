# frozen_string_literal: true

RSpec.describe Fetchworks do
  it "has a version number" do
    expect(Fetchworks::VERSION).not_to be_nil
  end
end

RSpec.describe OpenLibrary do
  context "when validating ISBN's" do
    it "raises InvalidISBN when ISBN is nil" do
      expect {
        described_class.get_book(nil)
      }.to raise_error OpenLibrary::InvalidISBN
    end

    it "raises InvalidISBN when ISBN is array" do
      expect {
        described_class.get_book(Array.new(10))
      }.to raise_error OpenLibrary::InvalidISBN
    end

    it "raises InvalidISBN when number is too short" do
      expect {
        described_class.get_book("123")
      }.to raise_error OpenLibrary::InvalidISBN
    end

    it "raises InvalidISBN when number is too long" do
      expect {
        described_class.get_book("123456789101112")
      }.to raise_error OpenLibrary::InvalidISBN
    end

    it "raises InvalidISBN when number is between ISBN10 and ISBN13" do
      expect {
        described_class.get_book("123456789101")
      }.to raise_error OpenLibrary::InvalidISBN
    end

    it "raises InvalidISBN when valid length with invalid char" do
      expect {
        described_class.get_book("1234s67890")
      }.to raise_error OpenLibrary::InvalidISBN
    end
  end

  context "when parsing OpenLibrary date strings" do
    it "returns an empty array when passed nil" do
      expect(described_class.partial_date_from_str(nil)).to be_nil
    end

    it "returns an empty array when passed something that isn't a string" do
      expect(described_class.partial_date_from_str(Object.new)).to be_nil
    end

    it "returns the correct partial date for: YYYY" do
      expect(described_class.partial_date_from_str("1901")).to eq(PartialDate.new([1901]))
    end

    it "returns the correct partial date for: 'Month YYYY'" do
      expect(described_class.partial_date_from_str("February 1901")).to eq(PartialDate.new([1901, 2]))
    end

    it "returns the correct partial date for 'AbbrMonth YYYY" do
      expect(described_class.partial_date_from_str("Feb 1901")).to eq(PartialDate.new([1901, 2]))
    end

    it "returns the correct partial date for: 'Month DD, YYYY'" do
      expect(described_class.partial_date_from_str("February 20, 1901")).to eq(PartialDate.new([1901, 2, 20]))
    end

    it "returns the correct partial date for: 'AbbrMonth DD, YYYY'" do
      expect(described_class.partial_date_from_str("Feb 20, 1901")).to eq(PartialDate.new([1901, 2, 20]))
    end

    it "returns the correct partial date for: 'DD Month YYYY'" do
      expect(described_class.partial_date_from_str("20 February 1901")).to eq(PartialDate.new([1901, 2, 20]))
    end

    it "returns the correct partial date for: 'DD AbbrMonth YYYY'" do
      expect(described_class.partial_date_from_str("20 Feb 1901")).to eq(PartialDate.new([1901, 2, 20]))
    end
  end
end
