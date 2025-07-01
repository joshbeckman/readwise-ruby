# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Common Development Commands

- **Setup**: `bin/setup` - Installs gem dependencies via bundle install
- **Tests**: `bundle exec rspec` - Runs the full test suite using RSpec
- **Console**: `bin/console` - Opens IRB with the gem loaded for interactive testing
- **Install locally**: `bundle exec rake install` - Installs gem to local machine
- **Build**: `bundle exec rake build` - Builds the gem file
- **Release**: `bundle exec rake release` - Creates git tag, pushes commits/tags, and publishes to RubyGems
- **CLI**: `readwise` - Command-line tool to send HTML content to Readwise Reader

## Codebase Architecture

This is a Ruby gem that provides a client library for the Readwise API. The architecture follows standard Ruby gem conventions:

### Core Components

- **Client** (`lib/readwise/client.rb`): Main API client handling both V2 (Highlights) and V3 (Reader) APIs
  - V2 API (BASE_URL): Highlights, books, tags, daily review functionality
  - V3 API (V3_BASE_URL): Reader documents functionality
  - All HTTP requests use Net::HTTP with token-based authentication
  - Pagination handled automatically for export and document listing

- **Data Models**: Immutable structs representing API entities
  - `Book`: Represents a book with highlights, metadata, and tags
  - `Highlight`: Individual highlight with text, location, tags, and metadata
  - `Document`: Reader documents (articles, PDFs) with reading progress and categorization
  - `Tag`: Simple name/ID structure for organizing content
  - `Review`: Daily review sessions with associated highlights

### Key Patterns

- **Transformation Methods**: Private methods in Client (`transform_*`) convert API responses to Ruby objects
- **Serialization**: Create/Update classes have `serialize` methods for API payloads
- **Pagination**: Automatic cursor-based pagination for large result sets
- **Error Handling**: Custom `Readwise::Client::Error` for API failures

### Test Structure

- Tests use RSpec with file fixtures from `spec/fixtures/`
- JSON fixtures represent actual API responses for consistent testing
- Test files mirror the lib directory structure
- Uses `rspec-file_fixtures` gem for loading test data
- CLI tests in `spec/readwise_spec.rb` test error handling and argument validation

### CLI Tool

The gem includes a `readwise` CLI  with `document create` command that reads HTML content from a file and sends it to Readwise Reader:

- Requires `READWISE_API_KEY` environment variable
- Takes HTML file path as first argument
- Supports all DocumentCreate parameters as flags
- Example: `readwise document create --title="My Article" --html-file=content.html`