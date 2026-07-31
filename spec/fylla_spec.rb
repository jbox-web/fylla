# frozen_string_literal: true

require "spec_helper"

RSpec.describe Fylla do

  before { described_class.load("test") }

  describe "VERSION" do
    it "is defined" do
      expect(Fylla::VERSION).to_not be_nil
    end
  end

  describe "the instrumented Thor application" do
    it "still lists its commands when started without arguments" do
      output = capture_stdout { Zsh::PlainSubcommands::Main.start([]) }

      expect(output).to include("Commands")
    end

    it "still lists the commands of a subcommand" do
      output = capture_stdout { Zsh::PlainSubcommands::Main.start(["sub"]) }

      expect(output).to include("noopts", "withopts")
    end

    it "still runs a subcommand" do
      output = capture_stdout { Zsh::PlainSubcommands::Main.start(%w[sub noopts]) }

      expect(output).to eq "noopts\n"
    end
  end

  describe "help output" do
    it "describes the nested subcommands" do
      output = capture_stdout do
        Bash::CLI::SubcommandWithNestedSubcommandsAndOptions.start(["help"])
      end

      expect(output).to include("subcommand", "subcommand2", "plain")
    end

    it "describes a single command, own options and inherited class options alike" do
      output = capture_stdout do
        Bash::CLI::SubcommandWithNestedSubcommandsAndOptions.start(%w[help plain])
      end

      expect(output).to include("--opt1", "--class-opt", "plain subcommand")
    end
  end

end
