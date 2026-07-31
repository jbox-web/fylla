# frozen_string_literal: true

require "spec_helper"

# The golden-output examples prove what the generator writes. These prove the
# shells accept it: a script can be valid shell syntax and still be refused when
# completion actually runs.
RSpec.describe Fylla::Thor::CompletionGenerator do

  describe "the generated bash script" do
    subject(:script) { bash_script(Bash::CLI::SubcommandWithNestedSubcommandsAndOptions) }

    before { skip "bash is not available" unless shell_available?("bash") }

    it "offers the top level commands" do
      candidates = bash_completions(script, ["test", ""], 1, "_test")

      expect(candidates).to include("help", "generate", "plain", "subcommand", "subcommand2")
    end

    it "offers the options of a leaf command" do
      candidates = bash_completions(script, ["test", "plain", ""], 2, "_test_plain")

      expect(candidates).to include("--opt1", "--help", "-h")
    end

    it "offers the commands of a nested subcommand" do
      candidates = bash_completions(script, ["test", "subcommand", ""], 2, "_test_subcommand")

      expect(candidates).to include("plain", "help")
    end
  end

  # A command mapped to another name (map "install" => :setup) is reachable under
  # that name, so completion must offer it. Flag aliases (-v, and the -h / -? / -D
  # Thor injects into every application) are options, not commands, and must stay
  # out of the command list.
  describe "the generated bash script for aliased commands" do
    subject(:script) { bash_script(Bash::CLI::Aliased) }

    before { skip "bash is not available" unless shell_available?("bash") }

    it "offers the alias alongside the method name" do
      candidates = bash_completions(script, ["test", ""], 1, "_test")

      expect(candidates).to include("setup", "install")
    end

    it "does not offer flag aliases as commands" do
      candidates = bash_completions(script, ["test", ""], 1, "_test")

      expect(candidates).to_not include("-v", "-h", "-?", "-D")
    end

    # An alias node for a subcommand would emit a second copy of the whole nested
    # function tree under a different breadcrumb; the subcommand itself is still
    # offered under its own name.
    it "does not offer an alias that points at a subcommand" do
      candidates = bash_completions(script, ["test", ""], 1, "_test")

      expect(candidates).to include("subcommand")
      expect(candidates).to_not include("sc")
    end
  end

  describe "the generated zsh script" do
    subject(:script) { zsh_script(Zsh::HostileDescriptions::Main, "hostile") }

    before { skip "zsh is not available" unless shell_available?("zsh") }

    it "produces an optspec zsh accepts when the description holds brackets" do
      expect(zsh_arguments_error(optspec_for(script, "--opt="))).to be_nil
    end

    it "produces an optspec zsh accepts when the description holds a backslash" do
      expect(zsh_arguments_error(optspec_for(script, "--slash="))).to be_nil
    end
  end

  describe "shell metacharacters in a description" do
    subject(:script) { zsh_script(Zsh::HostileDescriptions::Main, "hostile") }

    it "neutralises a command substitution" do
      expect(optspec_for(script, "--sub=")).to include('\\$(hostname)')
    end

    it "neutralises a backtick" do
      expect(optspec_for(script, "--tick=")).to include('\\`date\\`')
    end

    it "neutralises brackets" do
      expect(optspec_for(script, "--opt=")).to include('\\[a|b\\]')
    end
  end

end
