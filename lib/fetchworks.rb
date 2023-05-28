# frozen_string_literal: true

require_relative "fetchworks/version"

module OpenLibrary
  def self.get(isbn)
    isbn = isbn.to_s unless isbn.is_a? String
    isbn = isbn.strip

    # Primitive ISBN check: regex match for a 10 or 12 digit number
    # TODO: check prefix and checksum
    raise "InvalidISBN" unless /\A\d{10}(\d{3})?\z/.match? isbn 

    query = "bibkeys=ISBN:#{isbn}#{QUERY_POSTFIX}"
    uri = URI::HTTPS.build(host: HOST, path: PATH, query: query)
    JSON.parse(uri.open.read)["ISBN:#{isbn}"]
  end
end

class OpenLibraryBook
  include OpenLibrary
  attr_reader :title, :authors, :publish_date, :identifiers, :classifications,
              :publishers, :publish_places, :cover, :book_json_tree

  # Identifier is assumed to be ISBN10/ISBN13
  # TODO: Add a check or identification type
  def initialize(ident)
    @book_json_tree = OpenLibrary.get(ident).transform_keys(&:to_sym)
  end
end

module Fetchworks
  class Error < StandardError; end
  # Your code goes here...
end
