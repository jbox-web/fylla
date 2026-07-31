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
