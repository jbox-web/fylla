# frozen_string_literal: true

module Fylla
  #
  # A node of the command tree: a Thor class holding further commands, plus
  # the +class_options+ inherited by all of them. Rendered through the
  # +subcommand.erb+ template, which emits a dispatching function.
  #
  # The whole application is itself wrapped in one of these, with a +nil+ name,
  # so that the top level needs no special case.
  class ParsedSubcommand
    attr_accessor :name, :description, :commands, :class_options

    def initialize(name, description, commands, class_options)
      @name = name
      @description = description
      @commands = commands
      @class_options = class_options
    end
  end
end
