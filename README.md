# Readwise

[Readwise](https://readwise.io/) is an application suite to store, revisit, and learn from your book and article highlights. This is a basic library to call the [Readwise API](https://readwise.io/api_deets) to read and write highlights.

This library is not at 100% coverage of the API, so if you need a method that is missing, open an issue or contribute changes!

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'readwise'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install readwise

## Usage

First, obtain an API access token from https://readwise.io/access_token.

```ruby
client = Readwise::Client.new(token: token)

books = client.export # export all highlights
books = client.export(updated_after: '2023-01-17T22:02:48Z') # export recent highlights
books = client.export(book_ids: ['123']) # export specific highlights

puts books.first.title # books are Readwise::Book structs
puts books.first.highlights.map(&:text) # highlights are Readwise::Highlight structs
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/andjosh/readwise. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Readwise project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/andjosh/readwise/blob/master/CODE_OF_CONDUCT.md).
