# frozen_string_literal: true

require_relative "shell_escape"
require_relative "templates"
require_relative "parsed_option"
require_relative "parsed_command"
require_relative "parsed_subcommand"

module Fylla
  #
  # Walks a Thor application and renders its command tree as a completion
  # script.
  #
  # This is a plain object rather than a set of methods mixed into Thor: only
  # +zsh_completion+ and +bash_completion+ are added to Thor classes, so the
  # helpers below cannot collide with anything the host application defines.
  class Generator

    #
    # @param thor_class [Class] the Thor class to walk
    # @param executable_name [String] the name the completion is installed under
    def initialize(thor_class, executable_name)
      @thor_class = thor_class
      @executable_name = executable_name
    end

    # @return [String] the entire zsh completion script
    def zsh
      "#compdef _#{@executable_name} #{@executable_name}\n" \
        "#{render([root_command])}" \
        "_#{@executable_name} \"$@\""
    end

    # @return [String] the entire bash completion script
    def bash
      "#{render([root_command], style: :bash)}" \
        "complete -F _#{@executable_name} #{@executable_name}\n"
    end


    private


    # Wrap the whole application in a nameless subcommand, so that the top
    # level needs no special case anywhere downstream.
    def root_command
      commands = find_commands(@thor_class.all_commands, @thor_class.subcommand_classes, @thor_class.map)
      ParsedSubcommand.new(nil, "", commands, @thor_class.class_options.values)
    end

    # Render a list of nodes, accumulating the breadcrumb that names the shell
    # functions and the class options inherited from the levels above.
    #
    # @param context [String] breadcrumb of the current command path, so that
    #   "exe sub1 sub2" renders as "_sub1_sub2"
    def render(commands, context: "", class_options: [], style: :zsh)
      commands.map do |command|
        render_one(command, class_options, context_name(context, command), style)
      end.join
    end

    def context_name(context, command)
      return context if command.name.nil? || command.name.empty?

      "#{context}_#{command.name}"
    end

    def render_one(command, class_options, context_name, style)
      return Templates.fetch(style, :command).result(binding) unless command.is_a?(ParsedSubcommand)

      class_options = merge_class_options(class_options, command.class_options)
      # Children first: a shell function must be defined before the parent that
      # dispatches to it.
      children = render(command.commands,
                        context:       context_name,
                        class_options: class_options,
                        style:         style)

      children + Templates.fetch(style, :subcommand).result(binding)
    end

    # Turn Thor's two parallel maps into a tree. A command with no matching
    # entry in the subcommand map is a leaf.
    #
    # @param command_map [Hash<String, Thor::Command>]
    # @param subcommand_map [Hash<String, Class>]
    # @param aliases [Hash<String, Symbol>] Thor's +map+, alias => command name
    def find_commands(command_map, subcommand_map, aliases = {})
      nodes = command_map.to_h { |name, command| [command, subcommand_map[name]] }
                         .map { |command, klass| build_node(command, klass) }

      nodes + aliased_commands(nodes, aliases)
    end

    # A command declared under another name (map "install" => :setup) is
    # reachable under that name, so completion must offer it too.
    #
    # Three exclusions. Flag aliases are options, not commands: Thor injects
    # -h, -?, --help, -D, -t and --tree into every application, and an app may
    # add its own (-v). An alias spelled like a command that already exists
    # would emit a second, identical function and list the command twice in the
    # menu. Subcommands are left out as well — an alias node would emit a second
    # copy of the whole nested function tree under a different breadcrumb.
    def aliased_commands(nodes, aliases)
      leaves = nodes.grep(ParsedCommand).to_h { |node| [node.name.to_s, node] }
      taken = nodes.map { |node| node.name.to_s }

      aliases.filter_map { |name, target| alias_node(name.to_s, target.to_s, leaves, taken) }
    end

    def alias_node(name, target, leaves, taken)
      return if name.start_with?("-") || taken.include?(name)

      leaf = leaves[target]
      ParsedCommand.new(leaf.description, name, leaf.options) if leaf
    end

    def build_node(command, subcommand_class)
      if subcommand_class.nil?
        options = parse_options(command.options.values)
        return ParsedCommand.new(command.description, command.name, options)
      end

      # all_commands, not commands: a subcommand class inherits the commands of
      # its superclass, and those are just as invocable as its own. Reading
      # +commands+ here dropped every inherited one from the nested levels while
      # #root_command already read +all_commands+ at the top.
      commands = find_commands(subcommand_class.all_commands, subcommand_class.subcommand_classes,
                               subcommand_class.map)
      ParsedSubcommand.new(command.name, command.description, commands,
                           subcommand_class.class_options.values)
    end

    # Add the class options declared at this level to those inherited from the
    # levels above.
    #
    # Only the Thor options are parsed: re-parsing an already built
    # [ParsedOption] would read attributes it does not carry, silently dropping
    # the enum action and forcing the equals sign back on. Deduplication is by
    # switch name, an option redeclared further down being a different object.
    def merge_class_options(inherited, declared)
      (inherited + parse_options(declared)).uniq(&:name)
    end

    def parse_options(options)
      options.map do |opt|
        description = opt.completion || opt.description || opt.banner || opt.name.to_s.upcase
        ParsedOption.new(opt.name, description, opt.aliases, opt.enum, opt.filter, opt.type)
      end
    end

  end
end
