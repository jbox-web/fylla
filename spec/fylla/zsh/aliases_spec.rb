# frozen_string_literal: true

require "spec_helper"

RSpec.describe Fylla::Generator do

  subject(:script) { zsh_script(Zsh::Aliases::Main, "aliased") }

  describe "a command aliased under another name" do
    it "is listed in the command menu, under both names" do
      expect(script).to include(
        %('install:set the project up'\n),
        %('setup:set the project up'\n)
      )
    end

    it "gets its own completion function" do
      expect(script).to include("function _aliased_install {\n")
    end

    it "is dispatched to from the parent" do
      expect(script).to include("        install)\n          _aliased_install\n        ;;\n")
    end
  end

  describe "a flag alias" do
    # Thor injects -h, -?, --help, -D, -t and --tree into every application,
    # and an application may add its own. They are options, not commands.
    it "is kept out of the command menu" do
      expect(script).to_not include("'-v:", "'-h:", "'-t:", "'--help:", "'--tree:")
    end

    it "gets no completion function" do
      expect(script).to_not include("function _aliased_-v")
    end
  end

  describe "an alias spelled like the command it points at" do
    it "does not duplicate the menu entry" do
      expect(script.scan(%(    'setup:set the project up'\n)).size).to eq 1
    end

    it "does not define the completion function twice" do
      expect(script.scan("function _aliased_setup {\n").size).to eq 1
    end
  end

  describe "an alias pointing at a subcommand" do
    it "offers the subcommand under its own name only" do
      expect(script).to include(%('subcommand:nested subcommand'\n))
      expect(script).to_not include(%('sc:))
    end
  end

end
