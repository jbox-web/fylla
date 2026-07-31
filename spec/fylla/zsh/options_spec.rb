# frozen_string_literal: true

require "spec_helper"

RSpec.describe Fylla::Thor::CompletionGenerator do

  subject(:script) { zsh_script(app, "options") }

  describe "aliases" do
    context "when the option has none" do
      let(:app) { Zsh::OptionsApp::NoAliases }

      it "emits only the long switch" do
        expect(script).to include(%(    "--an_option=[AN_OPTION]" \\\n))
      end
    end

    context "when the option has one alias" do
      let(:app) { Zsh::OptionsApp::OneAlias }

      # Thor stores aliases dash-prefixed, so the template must not add one of
      # its own: `--a` is a switch Thor rejects at runtime.
      it "emits a single dash" do
        expect(script).to include(%(    "-a=[AN_OPTION]" \\\n))
      end

      it "never emits a double-dashed short alias" do
        expect(script).to_not include(%("--a=))
      end
    end

    context "when the option has several aliases" do
      let(:app) { Zsh::OptionsApp::ManyAliases }

      it "emits one entry per alias" do
        expect(script).to include(%(    "-a=[AN_OPTION]" \\\n), %(    "-b=[AN_OPTION]" \\\n))
      end
    end
  end

  describe "class options" do
    context "when no description is given" do
      let(:app) { Zsh::OptionsApp::ClassOptionNoDesc }

      it "falls back to the upcased name" do
        expect(script).to include(%(    "--klass[KLASS]" \\\n))
      end
    end

    context "when the application nests a subcommand" do
      let(:app) { Zsh::OptionsApp::ClassOptionNested }

      it "is inherited by the nested subcommand function" do
        expected = <<~'SCRIPT'
          function _options_sub {
            local line

            local -a commands
            commands=(
              'help:Describe subcommands or one specific subcommand'
              'withopts:subcommand that takes options'
            )

            _arguments \
              "--klass[KLASS]" \
              "-h[Show help information]" \
              "--help[Show help information]" \
              "1: : _describe 'command' commands" \
              "*::arg:->args"
        SCRIPT

        expect(script).to include(expected)
      end
    end
  end

end
