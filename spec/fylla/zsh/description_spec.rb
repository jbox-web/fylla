# frozen_string_literal: true

require "spec_helper"

RSpec.describe Fylla::Thor::CompletionGenerator do

  subject(:script) { zsh_script(app, "options") }

  describe "the source of the description" do
    context "when nothing is given" do
      let(:app) { Zsh::DescriptionSources::NoDescription }

      it "upcases the option name" do
        expect(script).to include(%("--an_option=[AN_OPTION]"))
      end
    end

    context "when a fylla completion text is given" do
      let(:app) { Zsh::DescriptionSources::FromCompletion }

      it "uses it" do
        expect(script).to include(%("--an_option=[a completion]"))
      end
    end

    context "when only desc is given" do
      let(:app) { Zsh::DescriptionSources::FromDesc }

      it "uses it" do
        expect(script).to include(%("--an_option=[a description]"))
      end
    end

    context "when only banner is given" do
      let(:app) { Zsh::DescriptionSources::FromBanner }

      it "uses it" do
        expect(script).to include(%("--an_option=[a banner]"))
      end
    end
  end

  describe "the precedence between the three sources" do
    let(:app) { Zsh::Precedence::Main }

    it "prefers the fylla completion text over desc and banner" do
      expect(script).to include(%("--test=[completion]"))
    end

    it "prefers desc over banner" do
      expect(script).to include(%("--test=[desc]"))
    end

    it "falls back to banner last" do
      expect(script).to include(%("--test=[banner]"))
    end
  end

  describe "switches that take no value" do
    let(:app) { Zsh::DescriptionSources::BooleanOption }

    it "omits the equals sign for a boolean option" do
      expect(script).to include(%("--an_option[AN_OPTION]"))
    end
  end

  describe "quoting" do
    let(:app) { Zsh::WeirdDescriptions::Main }

    it "escapes a single quote in a command description" do
      expect(script).to include(%('singlequote:Description with single quote '"'"''))
    end

    it "escapes a double quote in an option description" do
      expect(script).to include(%("--test=[option with double quote \\"]"))
    end
  end

end
