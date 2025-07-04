require_relative 'cli/base_command'
require_relative 'cli/command_registry'

module Readwise
  class CLI
    def self.start(args = ARGV)
      new.start(args)
    end

    def start(args)
      if args.empty?
        show_help
        exit 1
      end

      if args.first == '--help' || args.first == '-h'
        show_help
        return
      end

      resource = args.shift&.downcase
      action = args.shift&.downcase

      unless resource && action
        puts "Error: Resource and action are required"
        puts "Usage: readwise <resource> <action> [options] [arguments]"
        puts "Run 'readwise --help' for more information"
        exit 1
      end

      command_class = CommandRegistry.find(resource, action)
      unless command_class
        puts "Error: Unknown command '#{resource} #{action}'"
        puts "Run 'readwise --help' to see available commands"
        exit 1
      end

      command = command_class.new
      command.execute(args)
    rescue => e
      puts "Unexpected error: #{e.message}"
      exit 1
    end

    private

    def show_help
      puts <<~HELP
        Usage: readwise <resource> <action> [options] [arguments]

        Available commands:
          document create --html-file <file>    Send HTML content to Readwise Reader

        Global options:
          -h, --help               Show this help message

        Examples:
          readwise document create --html-file content.html --title="My Article"
          readwise document create -f content.html --title="My Article"
          readwise document create --help
      HELP
    end
  end
end
