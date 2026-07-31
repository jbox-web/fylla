# frozen_string_literal: true

require_relative "../test_helper"

module ThorExtensions
  class CommaArrayCli < Thor
    def self.exit_on_failure?
      true
    end

    desc "tags", "takes an array option"
    option :tags, type: :array
    def tags
      puts options["tags"].inspect
    end

    desc "envs", "takes an array option restricted by an enum"
    option :envs, type: :array, enum: %w[dev prod]
    def envs
      puts options["envs"].inspect
    end
  end
end

# Covers Fylla::Thor::Arguments#parse_array, which is prepended into
# Thor::Arguments as soon as fylla is required and therefore changes how every
# host application parses its own `type: :array` options.
class CommaArrayTest < Minitest::Test
  def parse(*argv)
    ARGV.clear
    out, = capture_io { ThorExtensions::CommaArrayCli.start(argv) }
    out.strip
  end

  def test_splits_a_comma_separated_value
    assert_equal %(["a", "b", "c"]), parse("tags", "--tags", "a,b,c")
  end

  def test_keeps_thor_space_separated_form
    assert_equal %(["a", "b", "c"]), parse("tags", "--tags", "a", "b", "c")
  end

  def test_returns_the_value_as_is_when_it_is_already_an_array
    assert_equal %(["a", "b"]), parse("tags", "--tags", %w[a b])
  end

  def test_keeps_empty_segments_produced_by_consecutive_commas
    assert_equal %(["a", "", "b"]), parse("tags", "--tags", "a,,b")
  end

  # CHARACTERIZATION, NOT DESIRED BEHAVIOUR.
  # Splitting is decided on the *first* token only: a comma appearing in any
  # later token is left untouched, so the two notations cannot be mixed.
  # See COR-comma_array_extension.rb:13 in the audit.
  def test_does_not_split_a_comma_in_a_later_token
    assert_equal %(["a", "b,c"]), parse("tags", "--tags", "a", "b,c")
  end

  # CHARACTERIZATION, NOT DESIRED BEHAVIOUR.
  # Thor validates every value of an enum array option in its own parse_array;
  # this override drops that call, so invalid values are silently accepted.
  # See COR-comma_array_extension.rb:9 in the audit.
  def test_does_not_validate_enum_values
    assert_equal %(["bogus"]), parse("envs", "--envs", "bogus")
  end
end
