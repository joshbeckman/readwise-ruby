# Readwise

[![Gem Version](https://badge.fury.io/rb/readwise.svg)](https://badge.fury.io/rb/readwise) [![Ruby](https://github.com/joshbeckman/readwise-ruby/actions/workflows/ruby.yml/badge.svg)](https://github.com/joshbeckman/readwise-ruby/actions/workflows/ruby.yml)

[Readwise](https://readwise.io/) is an application suite to store, revisit, and learn from your book and article highlights. This is a basic library to call the [Readwise API](https://readwise.io/api_deets) to read and write highlights, and manage Reader documents through the [Reader API](https://readwise.io/reader_api).

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

### Highlights API (V2)

The [V2 API](https://readwise.io/api_deets) provides access to your highlights and books:

```ruby
client = Readwise::Client.new(token: token)

books = client.export # export all highlights
books = client.export(updated_after: '2023-01-17T22:02:48Z') # export recent highlights
books = client.export(book_ids: ['123']) # export specific highlights

puts books.first.title # books are Readwise::Book structs
puts books.first.highlights.map(&:text) # highlights are Readwise::Highlight structs

# create a highlight
create = Readwise::HighlightCreate.new(text: 'foobar', author: 'Joan')
highlight = client.create_highlight(highlight: create)

# update a highlight
update = Readwise::HighlightUpdate.new(text: 'foobaz', color: 'yellow')
updated = client.update_highlight(highlight: highlight, update: update)

# add a tag to a highlight
tag = Readwise::Tag.new(name: 'foobar')
added_tag = client.add_highlight_tag(highlight: highlight, tag: tag)

# update a tag on a highlight
added_tag.name = 'bing'
updated_tag = client.update_highlight_tag(highlight: highlight, tag: added_tag)

# remove a tag from a highlight
client.remove_highlight_tag(highlight: highlight, tag: added_tag)

# get daily review highlights
daily_review = client.daily_review
puts daily_review.id
puts daily_review.url
puts daily_review.completed?
puts daily_review.highlights.size
puts daily_review.highlights.first.text
```

### Reader API (V3)

The [V3 API](https://readwise.io/reader_api) provides access to Readwise Reader functionality for managing documents (articles, PDFs, etc.):

```ruby
# Get all documents
documents = client.get_documents

# Get documents with filters
documents = client.get_documents(
  updated_after: '2023-01-01T00:00:00Z',
  location: 'new',        # 'new', 'later', 'archive', or 'feed'
  category: 'article'     # 'article', 'email', 'rss', 'highlight', 'note', 'pdf', 'epub', 'tweet', 'video'
)

# Get a specific document
document = client.get_document(document_id: '123456')

puts document.title
puts document.author
puts document.url
puts document.reading_progress
puts document.location
puts document.category

# Check document properties
puts document.read?                    # reading progress >= 85%
puts document.read?(threshold: 0.5)    # custom threshold
puts document.parent?                  # is this a top-level document?
puts document.child?                   # is this a highlight/note of another document?

# Check location
puts document.in_new?
puts document.in_later?
puts document.in_archive?

# Check category
puts document.article?
puts document.pdf?
puts document.epub?
puts document.tweet?
puts document.video?
puts document.book?
puts document.email?
puts document.rss?
puts document.highlight?
puts document.note?

# Access timestamps
puts document.created_at_time
puts document.updated_at_time
puts document.published_date_time

# Create a new document
document_create = Readwise::DocumentCreate.new(
  url: 'https://example.com/article',
  title: 'My Article',
  author: 'John Doe',
  html: '<p>Article content</p>',
  summary: 'A brief summary',
  location: 'new',           # 'new', 'later', 'archive', or 'feed'
  category: 'article',       # 'article', 'email', 'rss', etc.
  tags: ['technology', 'programming'],
  notes: 'My personal notes',
  should_clean_html: true,
  saved_using: 'api'
)

document = client.create_document(document: document_create)

# Create multiple documents
documents = client.create_documents(documents: [document_create1, document_create2])
```

## Command Line Interface

This gem includes a `readwise` command-line tool for quickly sending HTML content to Readwise Reader.

First, set your API token:
```bash
export READWISE_API_KEY=your_token_here
```

Then use the CLI to send HTML files:
```bash
# Basic usage
readwise document create --html-file content.html
readwise document create --url https://datatracker.ietf.org/doc/html/rfc2324

# Short form flag
readwise document create -f content.html

# With options
readwise document create --html-file content.html --title="My Article" --location=later

# See all available options
readwise --help
readwise document create --help
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bundle exec rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/joshbeckman/readwise-ruby. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Readwise project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/joshbeckman/readwise-ruby/blob/main/CODE_OF_CONDUCT.md).
