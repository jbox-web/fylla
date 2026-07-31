# frozen_string_literal: true

require "thor"

module Bash
  module CLI
    class ThorHelper < Thor
      desc "generate", "generate completions"
      def generate
        puts Fylla.bash_completion(self)
      end
    end

    class Subcommand < ThorHelper
      desc "plain", "plain subcommand"
      def plain
        puts "plain complete"
      end
    end

    class SubcommandWithOptions < ThorHelper
      option :opt1
      desc "plain", "plain subcommand"
      def plain
        puts "plain complete"
      end
    end

    class SubcommandWithNestedSubcommandsAndOptions < ThorHelper
      class_option :class_opt, desc: "a global option"

      option :opt1
      desc "plain", "plain subcommand"
      def plain
        puts "plain complete"
      end

      desc "subcommand", "nested subcommand"
      subcommand "subcommand", Subcommand

      desc "subcommand2", "nested subcommand"
      subcommand "subcommand2", SubcommandWithOptions
    end

    # Commands reachable under a name that is not their method name. Thor keeps
    # those in +map+, which the completion must offer alongside the real names.
    class Aliased < ThorHelper
      map "install" => :setup
      map "-v" => :version
      # Aliasing a subcommand: deliberately not offered, see aliased_commands.
      map "sc" => :subcommand

      desc "setup", "set the project up"
      def setup; end

      desc "version", "print the version"
      def version; end

      desc "subcommand", "nested subcommand"
      subcommand "subcommand", Subcommand
    end
  end
end
