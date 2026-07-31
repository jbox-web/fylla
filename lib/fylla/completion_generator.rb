# frozen_string_literal: true

require_relative "generator"

module Fylla
  module Thor
    #
    # module for prepending into +Thor+
    # inserts methods into Thor that allow generating completion scripts
    #
    # Only the two entry points below are added to Thor classes; everything
    # else lives in [Fylla::Generator], so nothing here can collide with a
    # method the host application declares.
    module CompletionGenerator
      def self.prepended(base)
        base.singleton_class.prepend(ClassMethods)
      end

      #
      # Contains the methods +zsh_completion+ and +bash_completion+
      module ClassMethods
        #
        # Generates a zsh _[executable_name] completion
        # script for the entire Thor application
        #
        # @param executable_name [String]
        #   the name of the executable to generate the script for
        # @return [String] the entire zsh completion script
        def zsh_completion(executable_name)
          Fylla::Generator.new(self, executable_name).zsh
        end

        #
        # Generates a bash _[executable_name] completion
        # script for the entire Thor application
        #
        # @param executable_name [String]
        #   the name of the executable to generate the script for
        # @return [String] the entire bash completion script
        def bash_completion(executable_name)
          Fylla::Generator.new(self, executable_name).bash
        end
      end
    end
  end
end
