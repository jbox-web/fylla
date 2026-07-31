# frozen_string_literal: true

require "open3"
require "tmpdir"

# Runs generated scripts through the shells they target. Golden-output examples
# prove what the generator writes; these prove the shell accepts it.
module ShellHelper

  def shell_available?(shell)
    ENV.fetch("PATH", "").split(File::PATH_SEPARATOR)
       .any? { |dir| File.executable?(File.join(dir, shell)) }
  end

  # Source a generated bash script, call one of its functions with a simulated
  # command line, and return the candidates it puts in COMPREPLY.
  def bash_completions(script, words, cword, function)
    program = <<~BASH
      source "$1"
      COMP_WORDS=(#{words.map { |w| shell_quote(w) }.join(' ')})
      COMP_CWORD=#{cword}
      #{function}
      printf '%s\\n' "${COMPREPLY[@]}"
    BASH

    with_tempfile(script) do |path|
      out, _err, status = Open3.capture3("bash", "-c", program, "bash", path)
      raise "bash exited #{status.exitstatus}" unless status.success?

      out.split("\n").reject(&:empty?)
    end
  end

  # Return the comparguments error for one _arguments optspec, or nil when zsh
  # accepts it. `zsh -n` cannot answer this: the spec is valid shell syntax and
  # still rejected when completion runs.
  def zsh_arguments_error(optspec)
    checker = File.expand_path("zsh_arguments_check.zsh", __dir__)

    with_tempfile(optspec) do |path|
      out, = Open3.capture2("zsh", "-f", checker, path)
      out.strip.empty? ? nil : out.strip
    end
  end

  # Pull one optspec line out of a generated zsh script, by switch name.
  def optspec_for(script, switch)
    needle = "\"#{switch}"
    line = script.lines.find { |candidate| candidate.include?(needle) }

    line.to_s.sub(/\s*\\\s*\z/, "").strip
  end

  # A single quote cannot appear inside a single-quoted shell word: close the
  # quote, emit an escaped quote, reopen.
  ESCAPED_SINGLE_QUOTE = %q(K'"'"'K).delete("K")

  private

  def shell_quote(word)
    escaped = word.gsub("'", ESCAPED_SINGLE_QUOTE)
    "'#{escaped}'"
  end

  def with_tempfile(content)
    Dir.mktmpdir("fylla-shell") do |dir|
      path = File.join(dir, "payload")
      File.write(path, content)
      yield path
    end
  end

end

RSpec.configure { |config| config.include ShellHelper }
