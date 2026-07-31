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

  context "with consecutive commas" do
    let(:argv) { ["tags", "--tags", "a,,b"] }

    it "keeps the empty segments" do
      expect(parsed).to eq %(["a", "", "b"]\n)
    end
  end

  context "with Thor's own space separated form" do
    let(:argv) { ["tags", "--tags", "a", "b", "c"] }

    it "is still accepted" do
      expect(parsed).to eq %(["a", "b", "c"]\n)
    end
  end

  context "with a value that is already an array" do
    let(:argv) { ["tags", "--tags", %w[a b]] }

    it "returns it untouched" do
      expect(parsed).to eq %(["a", "b"]\n)
    end
  end

  # CHARACTERIZATION, NOT DESIRED BEHAVIOUR.
  # Splitting is decided on the *first* token only, so a comma appearing in any
  # later token is left untouched and the two notations cannot be mixed.
  context "with a comma in a later token" do
    let(:argv) { ["tags", "--tags", "a", "b,c"] }

    it "does not split it" do
      expect(parsed).to eq %(["a", "b,c"]\n)
    end
  end

  # CHARACTERIZATION, NOT DESIRED BEHAVIOUR.
  # Thor validates every value of an enum array option in its own parse_array;
  # this override drops that call, so invalid values are silently accepted.
  context "with a value outside the declared enum" do
    let(:argv) { ["envs", "--envs", "bogus"] }

    it "accepts it instead of rejecting it" do
      expect(parsed).to eq %(["bogus"]\n)
    end
  end

end
