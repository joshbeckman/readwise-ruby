module Readwise
  class CLI
    class CommandRegistry
      @commands = {}

      def self.register(resource, action, command_class)
        key = "#{resource}:#{action}"
        @commands[key] = command_class
      end

      def self.find(resource, action)
        key = "#{resource}:#{action}"
        @commands[key]
      end

      def self.all_commands
        @commands.keys.map { |key| key.split(':') }
      end
    end
  end
end

# Register available commands
require_relative 'document/create_command'
