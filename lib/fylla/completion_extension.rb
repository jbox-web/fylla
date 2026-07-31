# frozen_string_literal: true

require "thor"

# add more options to Thor::Option
#
# :completion => allows providing a custom completion description for zsh
# :filter => allows filtering completions for arrays based on past completions
module Fylla
  module Thor
    #
    # Module prepended into +Thor::Option+ to recognize the +fylla:+ key
    # accepted alongside Thor's own option settings:
    #
    #   option :env, fylla: { completion: "target environment", filter: false }
    #
    # +completion+ overrides the text shown next to the switch in the generated
    # script, ahead of +desc+ and +banner+. +filter+ controls whether an
    # +enum:+ array option removes already-typed values from further
    # completions; it defaults to +true+.
    #
    # Because the key is read in +#initialize+, +require "fylla"+ must happen
    # before any Thor command declares its options — an option built earlier
    # keeps +nil+ for both readers.
    module Option
      attr_accessor :completion, :filter

      def initialize(name, options = {})
        @completion = options[:fylla]&.[](:completion)
        @filter = options[:fylla]&.[](:filter)
        @filter = true if @filter.nil?
        super
      end
    end
  end
end
