require_relative '../base_command'
require_relative '../../constants'
require 'uri'
require 'date'

module Readwise
  class CLI
    module Document
      class CreateCommand < BaseCommand
        def banner
          "Usage: readwise document create [options]"
        end

        def description
          "Sends HTML content to Readwise Reader API"
        end

        def add_options(opts)
          opts.on("-f", "--html-file=FILE", "HTML file path") do |file|
            options[:file] = file
          end

          opts.on("--title=TITLE", "Document title") do |title|
            options[:title] = title
          end

          opts.on("--author=AUTHOR", "Document author") do |author|
            options[:author] = author
          end

          opts.on("-u", "--url=URL", "Source URL (defaults to https://example.com/<filename>)") do |url|
            unless valid_url?(url)
              puts "Error: Invalid URL format. Please provide a valid URL."
              exit 1
            end
            options[:url] = url
          end

          opts.on("--summary=SUMMARY", "Document summary") do |summary|
            options[:summary] = summary
          end

          opts.on("--notes=NOTES", "Personal notes") do |notes|
            options[:notes] = notes
          end

          opts.on("--location=LOCATION", "Document location: #{Readwise::Constants::DOCUMENT_LOCATIONS.join(', ')} (default: new)") do |location|
            unless Readwise::Constants::DOCUMENT_LOCATIONS.include?(location)
              puts "Error: Invalid location. Must be one of: #{Readwise::Constants::DOCUMENT_LOCATIONS.join(', ')}"
              exit 1
            end
            options[:location] = location
          end

          opts.on("--category=CATEGORY", "Document category: #{Readwise::Constants::DOCUMENT_CATEGORIES.join(', ')}") do |category|
            unless Readwise::Constants::DOCUMENT_CATEGORIES.include?(category)
              puts "Error: Invalid category. Must be one of: #{Readwise::Constants::DOCUMENT_CATEGORIES.join(', ')}"
              exit 1
            end
            options[:category] = category
          end

          opts.on("--tags=TAGS", "Comma-separated list of tags") do |tags|
            options[:tags] = tags.split(',').map(&:strip)
          end

          opts.on("--image-url=URL", "Image URL") do |image_url|
            options[:image_url] = image_url
          end

          opts.on("--published-date=DATE", "Published date (ISO 8601 format)") do |date|
            unless valid_iso8601_date?(date)
              puts "Error: Invalid date format. Please provide a valid ISO 8601 date (e.g., 2023-12-25T10:30:00Z)."
              exit 1
            end
            options[:published_date] = date
          end

          opts.on("--[no-]clean-html", "Clean HTML (default: true)") do |clean|
            options[:should_clean_html] = clean
          end

          opts.on("--saved-using=SOURCE", "Saved using source (default: cli)") do |source|
            options[:saved_using] = source
          end
        end

        def validate_arguments(args)
          unless options[:file] || options[:url]
            puts "Error: File path or URL is required"
            show_help
            exit 1
          end
        end

        def run(args)
          html_file = options[:file]
          html_content = read_file(html_file) if html_file

          document_params = build_document_params(html_content, html_file)

          handle_api_error do
            client = get_api_client
            document_create = Readwise::DocumentCreate.new(**document_params)
            document = client.create_document(document: document_create)

            puts "Document created successfully!"
            puts "ID: #{document.id}"
            puts "Title: #{document.title}"
            puts "Location: #{document.location}"
            puts "URL: #{document.url}" if document.url
          end
        end

        private

        def valid_url?(url)
          uri = URI.parse(url)
          uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
        rescue URI::InvalidURIError
          false
        end

        def valid_iso8601_date?(date)
          DateTime.iso8601(date)
          true
        rescue Date::Error
          false
        end

        def build_document_params(html_content, html_file)
          document_params = {
            html: html_content,
            location: options[:location] || 'new',
            should_clean_html: options.key?(:should_clean_html) ? options[:should_clean_html] : true,
            saved_using: options[:saved_using] || 'cli',
            url: options[:url] || "https://example.com/#{File.basename(html_file)}"
          }

          [:title, :author, :summary, :notes, :category, :tags, :image_url, :published_date].each do |key|
            document_params[key] = options[key] if options[key]
          end

          document_params
        end
      end
    end
  end
end

# Register this command
Readwise::CLI::CommandRegistry.register('document', 'create', Readwise::CLI::Document::CreateCommand)
