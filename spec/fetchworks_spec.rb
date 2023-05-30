# frozen_string_literal: true

RSpec.describe Fetchworks do
  it "has a version number" do
    expect(Fetchworks::VERSION).not_to be nil
  end
end

RSpec.describe OpenLibrary do
  context "When validating ISBN's" do
    it "raises InvalidISBN when ISBN is nil" do
      expect {
        OpenLibrary.get_book(nil)
      }.to raise_error OpenLibrary::InvalidISBN
    end
    it "raises InvalidISBN when ISBN is array" do
      expect {
        OpenLibrary.get_book(Array.new(10))
      }.to raise_error OpenLibrary::InvalidISBN
    end
    it "raises InvalidISBN when number is too short" do
      expect {
        OpenLibrary.get_book('123')
      }.to raise_error OpenLibrary::InvalidISBN
    end
    it "raises InvalidISBN when number is too long" do
      expect { 
        OpenLibrary.get_book('123456789101112')
      }.to raise_error OpenLibrary::InvalidISBN
    end
    it "raises InvalidISBN when number is between ISBN10 and ISBN13" do
      expect { 
        OpenLibrary.get_book('123456789101')
      }.to raise_error OpenLibrary::InvalidISBN
    end
    it "raises InvalidISBN when valid length with invalid char" do
      expect { 
        OpenLibrary.get_book('1234s67890')
      }.to raise_error OpenLibrary::InvalidISBN
    end
  end
end
