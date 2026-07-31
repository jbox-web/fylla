# frozen_string_literal: true

require "thor"

# Modify how Thor parses array arguments to be POSIX standard per
# getopt_long(3)
# @see https://linux.die.net/man/3/getopt_long
module Fylla
  module Thor
    #
    # Module prepended into +Thor::Arguments+ so that +type: :array+ options
    # accept a comma-separated list (+--tags a,b,c+) in addition to Thor's
    # default space-separated form (+--tags a b c+).
    #
    # This changes argument parsing for the whole host application as soon as
    # +fylla+ is required, not only while a completion script is generated.
    module Arguments
      #
      # Consume every value of an array option, splitting each one on commas.
      #
      # Both notations mix freely: `--tags a,b c` and `--tags a b,c` yield the
      # same three elements. Empty segments, which `a,,b` would otherwise
      # produce, are dropped.
      #
      # Each value is checked against the option's `enum:` exactly as Thor does
      # in its own implementation. Skipping that check would silently accept
      # values the application declared as invalid.
      def parse_array(name)
        return shift if peek.is_a?(Array)

        array = []
        while current_is_value?
          shift.split(",").each do |value|
            next if value.empty?

            validate_enum_value!(name, value, "Expected all values of '%s' to be one of %s; got %s")
            array << value
          end
        end
        array
      end
    end
  end
end
