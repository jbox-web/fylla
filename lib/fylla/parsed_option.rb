# frozen_string_literal: true

module Fylla
  #
  # A +Thor::Option+ reduced to what the ERB templates need: the switch name,
  # its aliases, the text to display, and two precomputed shell fragments.
  #
  # +equals_type+ is +"="+ for every option that takes a value and +""+ for
  # booleans. +action+ is the zsh completion action derived from +enum:+ —
  # a +_values+ / +_sequence+ call for arrays, a plain alternatives list for
  # strings, and an empty string when the option has no +enum:+.
  class ParsedOption
    attr_accessor :aliases, :description, :name
    # Read by the ERB templates.
    attr_reader :action, :equals_type, :switch_name

    # rubocop:disable Metrics/MethodLength, Metrics/ParameterLists
    def initialize(name, description, aliases, enum, filter, type)
      @name = name
      @description = description
      # Thor >= 1.3 already stores aliases dash-prefixed ("-a"), older versions
      # store them bare ("a"). Normalize so templates can emit them verbatim.
      @aliases = Array(aliases).map { |a| a.to_s.sub(/^(?!-)/, "-") }
      # Thor's canonical spelling, underscores dashified, as shown by `thor help`
      @switch_name = "--#{name.to_s.tr('_', '-')}"
      # used for switches that take values (everything, but not necessary for boolean)
      @equals_type = type == :boolean ? "" : "="
      @action = ""
      return unless enum

      case type
      when :array
        @action = if filter
                    %(: :_values -s , 'options' #{enum.join(' ')})
                  else
                    %(: :_sequence -d compadd - #{enum.join(' ')})
                  end
      when :string
        @action = %|: :(#{enum.join(' ')})|
      end
    end
    # rubocop:enable Metrics/MethodLength, Metrics/ParameterLists
  end
end
