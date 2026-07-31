# frozen_string_literal: true

require "fylla/version"
require "fylla/completion_generator"
require "fylla/parsed_command"
require "fylla/parsed_subcommand"
require "fylla/completion_extension"
require "fylla/thor/extensions/comma_array_extension"
require "thor"

# We _must prepend before thor loads_ Ideally this is at require time...
Thor::Option.prepend Fylla::Thor::Option
Thor::Arguments.prepend Fylla::Thor::Arguments

#
# Top level module for the Fylla project.
# Contains one method for initializing Fylla
#
module Fylla
  #
  # this method initializes [Fylla]
  # Call this _before_ #Thor.start is called.
  # @param executable_name [String] name of your thor executable, must be provided
  # here or through #self.zsh_completion or #self.bash_completion
  def self.load(executable_name = nil)
    @executable_name = executable_name
    ::Thor.prepend Fylla::Thor::CompletionGenerator
  end

  #
  # Method to generate zsh completions for the current [Thor] application
  # @param thor_instance [Thor] _must always be self_
  # @param executable_name [String] name of your thor executable,
  #   must either be provided through #self.load or here.
  # @raise [ArgumentError] when no executable name is available
  # @return [String] containing the entire zsh completion script.
  def self.zsh_completion(thor_instance, executable_name = @executable_name)
    thor_instance.class.zsh_completion(check_executable_name!(executable_name))
  end

  #
  # Method to generate bash completions for the current [Thor] application
  # @param thor_instance [Thor] _must always be self_
  # @param executable_name [String] name of your thor executable,
  #   must either be provided through #self.load or here.
  # @raise [ArgumentError] when no executable name is available
  # @return [String] containing the entire bash completion script.
  def self.bash_completion(thor_instance, executable_name = @executable_name)
    thor_instance.class.bash_completion(check_executable_name!(executable_name))
  end

  #
  # Without a name the generator still produces a script, but one naming every
  # function `_` — valid shell, completely inert, and exiting 0. Fail loudly
  # instead of letting the caller install it.
  def self.check_executable_name!(executable_name)
    return executable_name unless executable_name.nil? || executable_name.to_s.empty?

    raise ArgumentError,
          "fylla needs the executable name: pass it to Fylla.load or to the completion method"
  end
  private_class_method :check_executable_name!
end
