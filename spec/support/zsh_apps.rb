# frozen_string_literal: true

require_relative "thor_test"

module Zsh
  module PlainSubcommands
    class Subcommand < ThorTest
      desc "noopts", "subcommand that takes no options"
      def noopts
        puts "noopts"
      end

      desc "withopts", "subcommand that takes options"
      option :an_option
      def withopts
        puts "with options"
      end
    end

    class Main < ThorTest
      desc "sub", "a subcommand"
      subcommand "sub", Subcommand
    end
  end

  module OptionsApp
    class NoAliases < ThorTest
      desc "withopts", "subcommand that takes options"
      option :an_option
      def withopts
        puts "with options"
      end
    end

    class OneAlias < ThorTest
      desc "withopts", "subcommand that takes options"
      option :an_option, aliases: %w[a]
      def withopts
        puts "with options"
      end
    end

    class ManyAliases < ThorTest
      desc "withopts", "subcommand that takes options"
      option :an_option, aliases: %w[a b]
      def withopts
        puts "with options"
      end
    end

    class ClassOptionNoDesc < ThorTest
      class_option :klass

      desc "withopts", "subcommand that takes options"
      def withopts
        puts "with options"
      end
    end

    class NestedSub < ThorTest
      desc "withopts", "subcommand that takes options"
      def withopts; end
    end

    class ClassOptionNested < ThorTest
      class_option :klass
      desc "withopts", "subcommand that takes options"
      subcommand "sub", NestedSub
    end
  end

  module DescriptionSources
    class NoDescription < ThorTest
      desc "withopts", "subcommand that takes options"
      option :an_option
      def withopts; end
    end

    class BooleanOption < ThorTest
      desc "withopts", "subcommand that takes options"
      option :an_option, type: :boolean
      def withopts; end
    end

    class FromCompletion < ThorTest
      desc "withopts", "subcommand that takes options"
      option :an_option, fylla: { completion: "a completion" }
      def withopts; end
    end

    class FromDesc < ThorTest
      desc "withopts", "subcommand that takes options"
      option :an_option, desc: "a description"
      def withopts; end
    end

    class FromBanner < ThorTest
      desc "withopts", "subcommand that takes options"
      option :an_option, banner: "a banner"
      def withopts; end
    end
  end

  module Precedence
    class Main < ThorTest
      desc "completion", "use completion flag for description"
      option :test,
             fylla:  { completion: "completion" },
             desc:   "shouldn't be used if completion is present",
             banner: "shouldn't be used if completion is present"
      def completion; end

      desc "desc", "use description flag for description"
      option :test,
             desc:   "desc",
             banner: "shouldn't be used if desc is present"
      def desc; end

      desc "banner", "use banner flag for description"
      option :test, banner: "banner"
      def banner; end
    end
  end

  module Enums
    class Main < ThorTest
      desc "command", "command"
      option :test, enum: %w[enum1 enum2 enum3]
      def command; end

      desc "command2", "command2"
      option :test,
             type: :array,
             enum: %w[enum1 enum2 enum3]
      def command2; end

      desc "command3", "command3"
      option :test,
             type:  :array,
             enum:  %w[enum1 enum2 enum3],
             fylla: { filter: false }
      def command3; end

      desc "command4", "command4"
      option :test
      def command4; end

      desc "command5", "command5"
      option :test,
             type: :numeric,
             enum: [1, 2, 3]
      def command5; end
    end
  end

  # Descriptions carrying characters that are meaningful to zsh: brackets
  # delimit the description inside an _arguments optspec, and `$(…)` / backticks
  # are substituted when the completion function runs.
  module HostileDescriptions
    class Main < ThorTest
      desc "brackets", "a command"
      option :opt, desc: "value [a|b] required"
      def brackets; end

      desc "substitution", "a command"
      option :sub, desc: "defaults to $(hostname)"
      def substitution; end

      desc "backtick", "a command"
      option :tick, desc: "uses `date` internally"
      def backtick; end

      desc "backslash", "a command"
      option :slash, desc: "ends with a backslash \\"
      def backslash; end
    end
  end

  module WeirdDescriptions
    class Main < ThorTest
      desc "singlequote", "Description with single quote '"
      option :test, fylla: { completion: "option with single quote '" }
      def singlequote; end

      desc "doublequote", 'Description with double quote "'
      option :test, fylla: { completion: 'option with double quote "' }
      def doublequote; end
    end
  end
end
