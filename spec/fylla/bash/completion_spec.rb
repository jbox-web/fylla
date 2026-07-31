# frozen_string_literal: true

require "spec_helper"

RSpec.describe Fylla::Thor::CompletionGenerator do

  subject(:script) { bash_script(app) }

  # Emitted for every command that carries no subcommand of its own.
  def leaf(name, *options)
    switches = options.map { |o| %(    options+=("#{o}")\n) }.join
    <<~HEAD + switches + <<~TAIL
      _test_#{name} ()
      {
        local cur="${COMP_WORDS[COMP_CWORD]}"
        local options=()
    HEAD
        options+=("--help")
        options+=("-h")
        COMPREPLY=($(compgen -W "${options[*]}" -- "$cur"))
      }
    TAIL
  end

  context "with an application without options" do
    let(:app) { Bash::CLI::Subcommand }

    it "emits one function per command" do
      expect(script).to include(leaf("help"), leaf("tree"), leaf("generate"), leaf("plain"))
    end

    it "completes the command list and registers the entry point" do
      expect(script).to include(
        %(COMPREPLY=($(compgen -W "help tree generate plain " -- "$cur"))),
        "complete -F _test test\n"
      )
    end
  end

  context "with an application declaring a command option" do
    let(:app) { Bash::CLI::SubcommandWithOptions }

    it "adds the switch to the function of that command alone" do
      expect(script).to include(leaf("plain", "--opt1"), leaf("generate"))
    end
  end

  context "with an application nesting subcommands" do
    let(:app) { Bash::CLI::SubcommandWithNestedSubcommandsAndOptions }

    it "emits a dispatcher per nesting level" do
      expect(script).to include("_test_subcommand() {", "_test_subcommand2() {", "_test() {")
    end

    it "names the nested functions after the full command path" do
      expect(script).to include(leaf("subcommand_plain"), leaf("subcommand2_plain", "--opt1"))
    end

    it "dispatches to the nested subcommand" do
      # The template indents the case arms with literal leading spaces, so the
      # expectation cannot go through a squiggly heredoc.
      expected = [
        "          subcommand)\n",
        "            _test_subcommand\n",
        "            return ;;\n",
        "          subcommand2)\n",
        "            _test_subcommand2\n",
        "            return ;;\n",
      ].join

      expect(script).to include(expected)
    end

    it "offers the class option at the top level, dashified by Thor" do
      expect(script).to include(
        %(compgen -W "help tree generate plain subcommand subcommand2 --class-opt" -- "$cur")
      )
    end

    # CHARACTERIZATION, NOT DESIRED BEHAVIOUR.
    # The bash subcommand template reads the node's own class_options instead of
    # the set accumulated while walking down the tree, so a class option
    # declared on the parent is not offered inside its subcommands. The zsh
    # template does inherit it.
    it "does not offer the inherited class option inside a subcommand" do
      expect(script).to include(%(COMPREPLY=($(compgen -W "plain help " -- "$cur"))))
    end
  end

end
