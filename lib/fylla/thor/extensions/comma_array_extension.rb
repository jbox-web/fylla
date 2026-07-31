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
      def parse_array(_name)
        return shift if peek.is_a?(Array)

        array = []
        if peek.include? ","
          array.push(*shift.split(","))
        else
          array << shift while current_is_value?
        end
        array
      end
    end
  end
end
