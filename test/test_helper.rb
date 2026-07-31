# frozen_string_literal: true

require "simplecov"
SimpleCov.start

require "minitest/autorun"
require "minitest/hooks/default"

def matches(expected)
  Regexp.new(Regexp.escape(expected))
end

require "fylla"
require "fylla/completion_generator"
require "fylla/completion_extension"
