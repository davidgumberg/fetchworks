# frozen_string_literal: true

require_relative "fetchworks/version"

require "json"
require "open-uri"

HOST = 'openlibrary.org'
PATH = '/api/books'
QUERY_POSTFIX = '&jscmd=data&format=json'

module OpenLibrary
  class InvalidISBN < StandardError; end

  def self.get_book(isbn)
    raise InvalidISBN unless isbn.is_a?(Integer) || isbn.is_a?(String)

    isbn = isbn.to_s if isbn.is_a? Integer
    isbn = isbn.strip

    # Primitive ISBN check: regex match for a 10 or 12 digit number
    # TODO: check prefix and checksum
    raise InvalidISBN unless /\A\d{10}(\d{3})?\z/.match? isbn 

    query = "bibkeys=ISBN:#{isbn}#{QUERY_POSTFIX}"
    uri = URI::HTTPS.build(host: HOST, path: PATH, query: query)
    JSON.parse(uri.open.read).values.first
  end

  def method_missing(method_name, *args, &block)
    key = method_name.to_s
    @data.key?(key) ? @data[key] : nil
  end

  def respond_to_missing?(method_name, include_private = false)
    key = method_name.to_s
    @data.key?(key) || super
  end

  def self.get_author(url)
    url = url[%r{\A.*(?=/)}] + '.json'
    uri = URI.parse(url)
    p uri
    JSON.parse(uri.open.read)
  end
end

class OpenLibraryBook
  include OpenLibrary

  attr_reader :data

  # Identifier is assumed to be ISBN10/ISBN13
  # TODO: Add a check or identification type
  def initialize(ident)
    @data = OpenLibrary.get_book(ident)
  end

  def authors_details
    authors.collect do |author|
      p author["url"]
      OpenLibrary.get_author(author["url"])
    end
  end
end

module Fetchworks
  class Error < StandardError; end
  # Your code goes here...
end
