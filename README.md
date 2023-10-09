# Fetchworks

A simple gem for fetching information about works and authors from various open databases. Today, Internet Archive's Open Library is supported.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add fetchworks

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install fetchworks

## Usage

```ruby
donquixote = OpenLibraryBook.new("9780062391667")

# OpenLibraryBook.data returns a hash of all the JSON data returned by OL
donquixote.data 
# => { "title": "Don Quixote Deluxe Edition", "number_of_pages": "992" [...] }
donquixote.data["title"] # => "Don Quixote Deluxe Edition"

# Use the author id's contained in a work, to request entries for the authors of a work
authors = donquixote.fetch_authors # => [#<OpenLibraryAuthor:0x01 @data={...}>, #<OpenLibraryAuthor:0x02 @data={...}> ...]

cervantes = authors[0] # => #<OpenLibraryAuthor:0x01>
cervantes.data
# => { "personal_name"=>"Miguel de Cervantes Saavedra",
#      "birth_date"=>"29 Sep 1547" ... }
cervantes.data["personal_name"]

# JSON data for OpenLibraryBook and OpenLibraryAuthor can be accessed with methods:
donquixote.number_of_pages # => "992"
cervantes.bio # => "Miguel de Cervantes Saavedra was a Spanish novelist, poet, [...]"

```

### Dates

Given the partial nature of historical dates (oftentimes a year is known but a
month or day isn't), we provide a class `PartialDate` to represent dates that
are accessed via method names:

```ruby
cervantes.birth_date # => #<PartialDate:0x01 @day=29, @month=9, @year=1547>
cervantes.birth_date.year # => 1547

donquixote.publish_date # => #<PartialDate:0x02 @day=16, @month=6, @year=2015>
donquixote.publish_date.day # => 16
```

If you still want to access the original string format of a date that
OpenLibrary provides, you can through the `@data` hash.

```ruby
cervantes.data["birth_date"] # => "29 Sep 1547"
```

`PartialDate` is furnished with the instance methods: `#year`, `#month`, and `#day`, which
work as expected when a value is present, and return `nil` when one isn't. We also provide
convenience methods `#to_date` and `#to_time` which will return a ruby builtin `Date` or `Time`
object with the smallest possible values for the unknown attributes of the date.

```ruby
herodotus.birth_date # => #<PartialDate:0x01 @day=nil, @month=nil, @year=-484>
herodotus.birth_date.month # => nil
herodotus.birth_date.day # => nil

ruby_date = herodotus.birth_date.to_date # => #<Date:...>
ruby_date.month # => 1
ruby_date.day # => 1

ruby_time = herodotus.birth_date.to_time # => #<Time:...>
ruby_time.hour => 0
ruby_time.sec => 0
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/davidgumberg/fetchworks.
