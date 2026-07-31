# frozen_string_literal: true

require "simplecov"
require "simplecov_json_formatter"

# Start SimpleCov
SimpleCov.start do
  enable_coverage :branch
  formatter SimpleCov::Formatter::MultiFormatter.new([SimpleCov::Formatter::HTMLFormatter,
                                                      SimpleCov::Formatter::JSONFormatter,])
  skip "spec/"
end

module FyllaTest
  # Run a Thor application and return what it wrote on stdout. Every fixture
  # prints its completion script, so this is what the examples assert on.
  def capture_stdout
    original = $stdout
    $stdout = StringIO.new
    yield
    $stdout.string
  ensure
    $stdout = original
  end

  def capture_stderr
    original = $stderr
    $stderr = StringIO.new
    yield
    $stderr.string
  ensure
    $stderr = original
  end

  def zsh_script(klass, executable_name = "test")
    Fylla.load(executable_name)
    capture_stdout { klass.start(["generate_completions"]) }
  end

  def bash_script(klass, executable_name = "test")
    Fylla.load(executable_name)
    capture_stdout { klass.start(["generate"]) }
  end
end

# Configure RSpec
RSpec.configure do |config|
  config.include FyllaTest

  config.color = true
  config.fail_fast = false

  config.order = :random
  Kernel.srand config.seed

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # disable monkey patching
  # see: https://relishapp.com/rspec/rspec-core/v/3-8/docs/configuration/zero-monkey-patching-mode
  config.disable_monkey_patching!

  config.raise_errors_for_deprecations!
end

# Load our gem. It must be loaded before any Thor class is declared, otherwise
# the fylla: option key is dropped from options built earlier.
require "fylla"

# Load the Thor applications the examples generate completions for
Dir[File.expand_path("support/**/*.rb", __dir__)].each { |file| require file }
