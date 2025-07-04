require 'optparse'

module Readwise
  class CLI
    class BaseCommand
      def initialize
        @options = {}
      end

      def execute(args)
        parse_options(args)
        validate_arguments(args)
        run(args)
      rescue OptionParser::InvalidOption => e
        puts "Error: #{e.message}"
        show_help
        exit 1
      rescue ArgumentError => e
        puts "Error: #{e.message}"
        exit 1
      end

      private

      attr_reader :options

      def parse_options(args)
        parser = create_option_parser
        parser.parse!(args)
      end

      def create_option_parser
        OptionParser.new do |opts|
          opts.banner = banner
          opts.separator ""
          opts.separator description if description
          opts.separator ""
          opts.separator "Options:"

          add_options(opts)

          opts.on("-h", "--help", "Show this help message") do
            show_help
            exit
          end
        end
      end

      def show_help
        puts create_option_parser.help
      end

      def get_api_client
        token = ENV['READWISE_API_KEY']
        unless token
          puts "Error: READWISE_API_KEY environment variable is not set"
          exit 1
        end

        Readwise::Client.new(token: token)
      end

      def read_file(file_path)
        unless File.exist?(file_path)
          puts "Error: File '#{file_path}' not found"
          exit 1
        end

        File.read(file_path)
      end

      def handle_api_error(&block)
        yield
      rescue Readwise::Client::Error => e
        puts "API Error: #{e.message}"
        exit 1
      rescue => e
        puts "Unexpected error: #{e.message}"
        exit 1
      end

      # Override these methods in subclasses

      def banner
        "Usage: readwise"
      end

      def description
        nil
      end

      def add_options(opts)
        # Override in subclasses to add specific options
      end

      def validate_arguments(args)
        # Override in subclasses to validate arguments
      end

      def run(args)
        raise NotImplementedError, "Subclasses must implement #run"
      end
    end
  end
end
