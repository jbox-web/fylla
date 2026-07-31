# frozen_string_literal: true

require "spec_helper"

RSpec.describe Fylla::Thor::CompletionGenerator do

  subject(:script) { zsh_script(Zsh::Enums::Main, "options") }

  it "lists the allowed values of a string enum" do
    expect(script).to include(%("--test=[TEST]: :(enum1 enum2 enum3)"))
  end

  it "uses _values for an array enum, which filters already typed values" do
    expect(script).to include(%(: :_values -s , 'options' enum1 enum2 enum3))
  end

  it "uses _sequence for an array enum declared with filter: false" do
    expect(script).to include(%(: :_sequence -d compadd - enum1 enum2 enum3))
  end

  it "emits no action for an option without enum" do
    expect(script).to include(%(function _options_command4 {\n  _arguments \\\n    "--test=[TEST]" \\\n))
  end

  # Only :array and :string produce an action; any other type falls through and
  # the switch is completed without its allowed values.
  it "emits no action for an enum declared on an unhandled type" do
    expect(script).to include(%(function _options_command5 {\n  _arguments \\\n    "--test=[N]" \\\n))
  end

end
