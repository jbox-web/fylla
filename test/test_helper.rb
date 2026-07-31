# frozen_string_literal: true

require "simplecov"
require "simplecov_json_formatter"

# Start SimpleCov
SimpleCov.start do
  enable_coverage :branch
  formatter SimpleCov::Formatter::MultiFormatter.new([SimpleCov::Formatter::HTMLFormatter,
                                                      SimpleCov::Formatter::JSONFormatter,])
  skip "test/"
end

require "minitest/autorun"
require "minitest/hooks/default"

def matches(expected)
  Regexp.new(Regexp.escape(expected))
end

require "fylla"
require "fylla/completion_generator"
require "fylla/completion_extension"
