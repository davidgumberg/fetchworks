# frozen_string_literal: true

OPENURI_OPTS = {
  read_timeout: 10,
  open_timeout: 10
}.freeze

require_relative "fetchworks/version"
require_relative "fetchworks/partial_date"

require "json"
require "time"
require "open-uri"
require "petrarca"

HOST = "openlibrary.org"
PATH = "/api/books"
QUERY_POSTFIX = "&jscmd=data&format=json"

# Mixin Module for classes with a hash attribute @data
# That routes classinstance.method to classinstance.data[:method]
# TODO: infect nested hashes and arrays with this module.

module HashMethodable
  # Expose hash members as methods
  def method_missing(method_name, *_args, &_block)
    key = method_name&.to_s
    @data&.key?(key) ? @data[key] : nil
  end

  # Advertise hash member methods
  def respond_to_missing?(method_name, include_private = false)
    key = method_name&.to_s
    @data&.key?(key) || super
  end
end

# Provides methods for accessing OpenLibrary resources
module OpenLibrary
  # Declare error classes
  class InvalidISBN < StandardError; end
  class OpenLibraryError < StandardError; end
  class OLBadStatus < OpenLibraryError; end
  class OLResourceNotFound < OpenLibraryError; end
  class OLDateStrUnparseable < OpenLibraryError; end

  def self.get_book(isbn)
    unless isbn.is_a?(Integer) || isbn.is_a?(String)
      raise InvalidISBN, "ISBN must be a string (or integer)"
    end

    # Strip whitespace and hyphens
    isbn = isbn.to_s.strip.delete("-")

    # Catch incorrect length ISBN's early
    unless isbn.length == 10 || isbn.length == 13
      raise InvalidISBN, "An ISBN must be either 10 or 13 digits long"
    end

    raise InvalidISBN unless Petrarca.valid?(isbn)

    query = "bibkeys=ISBN:#{isbn}#{QUERY_POSTFIX}"
    uri = URI::HTTPS.build(host: HOST, path: PATH, query: query)
    response = uri.open(**OPENURI_OPTS)

    if response&.status != ["200", "OK"]
      raise OLBadStatus, response&.status
    end

    response_body = response&.read
    raise OLResourceNotFound unless response_body != "{}"

    JSON.parse(response_body).values.first
  end

  def self.get_author(url)
    url = url[%r{\A.*(?=/)}] + ".json"
    uri = URI.parse(url)
    JSON.parse(uri.open.read)
  end

  # Returns a PartialDate from strings of one of the following four formats:
  # "YYYY" | "Month YYYY" | "Month DD, YYYY" | "DD Month, YYYY"
  #
  # "Month"s are abbreviated usually, but sometimes not.
  #
  # This gets nasty, because we have a number of formats when two
  # or three elements are present. We decide which one based off
  # of which member is a recognized month name.
  def self.partial_date_from_str(str)
    return nil unless str.is_a?(String) && !str.empty?

    # Replace commas with spaces and part out the date string
    split = str.tr(",", " ").split

    PartialDate.new(
      case split.length
      # e.g. "1991"
      when 1
        [split[0].to_i]

      when 2
        # e.g. "Jan 1991"
        if Date::ABBR_MONTHNAMES.include?(split[0])
          [split[1].to_i,
           Date::ABBR_MONTHNAMES.index(split[0])]

        # e.g. "January 1991"
        elsif Date::MONTHNAMES.include?(split[0])
          [split[1].to_i,
           Date::MONTHNAMES.index(split[0])]
        else
          raise OLDateStrUnparseable
        end

      when 3
        # e.g. "Jan 12, 1991"
        if Date::ABBR_MONTHNAMES.include?(split[0])
          [split[2].to_i,
           Date::ABBR_MONTHNAMES.index(split[0]),
           split[1].to_i]

        # e.g. "January 12, 1991"
        elsif Date::MONTHNAMES.include?(split[0])
          [split[2].to_i,
           Date::MONTHNAMES.index(split[0]),
           split[1].to_i]

        # e.g. "12 Jan 1991"
        elsif Date::ABBR_MONTHNAMES.include?(split[1])
          [split[2].to_i,
           Date::ABBR_MONTHNAMES.index(split[1]),
           split[0].to_i]

        # e.g. "12 January 1991"
        elsif Date::MONTHNAMES.include?(split[1])
          [split[2].to_i,
           Date::MONTHNAMES.index(split[1]),
           split[0].to_i]
        else
          raise OLDateStrUnparseable
        end
      end
    )
  end
end

# Methods common to OpenLibraryBook's and OpenLibraryAuthor's
# Exposes the JSON representation of an OL entry as a hash
# through @data, and as methods with method_missing,
class OpenLibraryEntry
  include HashMethodable

  attr_reader :data

  def initialize(data)
    raise StandardError unless data.is_a? Hash

    @data = data
  end
end

# A class that represents authors in the OpenLibrary database
class OpenLibraryAuthor < OpenLibraryEntry
  # Can only access authors at present via
  # the URL provided for them in book data
  def initialize(url)
    super OpenLibrary.get_author(url)
  end

  def birth_date
    str = @data["birth_date"]
    OpenLibrary.partial_date_from_str(str)
  end

  def death_date
    str = @data["death_date"]
    OpenLibrary.partial_date_from_str(str)
  end
end

# A class that represents books in the OpenLibrary database
# It exposes the JSON representation that OL provides through their API
# as a hash through @data, and as methods with method_missing,
# and handles some comple
class OpenLibraryBook < OpenLibraryEntry
  # Identifier is assumed to be ISBN10/ISBN13
  # TODO: Add a check or identification type
  def initialize(ident)
    super OpenLibrary.get_book(ident)
  end

  def publish_date
    str = @data["publish_date"]
    OpenLibrary.partial_date_from_str(str)
  end

  def fetch_authors
    authors.collect do |author|
      OpenLibraryAuthor.new author["url"]
    end
  end
end

# module Fetchworks
#  class Error < StandardError; end
#  # Your code goes here...
# end
