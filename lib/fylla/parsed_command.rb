# frozen_string_literal: true

module Fylla
  #
  # A leaf of the command tree: a Thor command that carries no subcommand of
  # its own. Rendered through the +command.erb+ template of the target shell,
  # which emits one completion function listing the command's own options.
  class ParsedCommand
    attr_accessor :description, :name, :options

    def initialize(description, name, options)
      @description = description
      @name = name
      @options = options
    end
  end
end
