# frozen_string_literal: true

require "spec_helper"

# This module is prepended into Thor::Arguments as soon as fylla is required,
# so it changes how every host application parses its own `type: :array`
# options, not only how completion scripts are generated.
RSpec.describe Fylla::Thor::Arguments do

  subject(:parsed) { capture_stdout { ThorExtensions::CommaArrayCli.start(argv) } }

  context "with a comma separated value" do
    let(:argv) { ["tags", "--tags", "a,b,c"] }

    it "splits it into one element per segment" do
      expect(parsed).to eq %(["a", "b", "c"]\n)
    end
  end

  context "with Thor's own space separated form" do
    let(:argv) { ["tags", "--tags", "a", "b", "c"] }

    it "is still accepted" do
      expect(parsed).to eq %(["a", "b", "c"]\n)
    end
  end

  context "with a comma in a later token" do
    let(:argv) { ["tags", "--tags", "a", "b,c"] }

    it "splits it too, the two notations mix freely" do
      expect(parsed).to eq %(["a", "b", "c"]\n)
    end
  end

  context "with a comma in the first token and more tokens after it" do
    let(:argv) { ["tags", "--tags", "a,b", "c"] }

    it "consumes every token instead of stopping at the first" do
      expect(parsed).to eq %(["a", "b", "c"]\n)
    end
  end

  context "with consecutive commas" do
    let(:argv) { ["tags", "--tags", "a,,b"] }

    it "drops the empty segments" do
      expect(parsed).to eq %(["a", "b"]\n)
    end
  end

  context "with a value that is already an array" do
    let(:argv) { ["tags", "--tags", %w[a b]] }

    it "returns it untouched" do
      expect(parsed).to eq %(["a", "b"]\n)
    end
  end

  describe "enum validation" do
    context "with values inside the declared enum" do
      let(:argv) { ["envs", "--envs", "dev,prod"] }

      it "accepts them" do
        expect(parsed).to eq %(["dev", "prod"]\n)
      end
    end

    # The fixture declares exit_on_failure?, as a real CLI does, so Thor reports
    # the error on stderr and exits rather than letting the exception through.
    context "with a value outside the declared enum" do
      let(:argv) { ["envs", "--envs", "bogus"] }

      it "rejects it, as Thor does for its own array options" do
        message = capture_stderr do
          expect { ThorExtensions::CommaArrayCli.start(argv) }.to raise_error(SystemExit)
        end

        expect(message).to include("Expected all values of '--envs' to be one of dev, prod")
      end
    end

    context "with a valid value and an invalid one in the same comma list" do
      let(:argv) { ["envs", "--envs", "dev,bogus"] }

      it "rejects the whole option" do
        message = capture_stderr do
          expect { ThorExtensions::CommaArrayCli.start(argv) }.to raise_error(SystemExit)
        end

        expect(message).to include("got bogus")
      end
    end
  end

end
