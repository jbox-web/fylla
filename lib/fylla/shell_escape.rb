# frozen_string_literal: true

module Fylla
  #
  # Escaping for text that ends up inside a generated completion script.
  #
  # A description is written by the CLI author, but it may well be built from a
  # variable, a config file or the output of a command, so it cannot be trusted
  # to be inert.
  module ShellEscape

    # Characters that change the meaning of a zsh `_arguments` optspec.
    #
    # The description sits inside `"--switch[<here>]"`, that is inside a
    # double-quoted word and inside the brackets comparguments uses to delimit
    # it. So:
    #   * `[` and `]` would end the description early — comparguments then
    #     rejects the whole optspec and completion dies for the entire command;
    #   * `$`, a backtick and `"` are still live inside double quotes, so they
    #     would be expanded, or would run a command, when the user hits TAB.
    #
    # The text crosses two layers, which is why the backslash is quadrupled and
    # the others are not. Double quoting resolves `\\` to `\` and `\$` to `$`,
    # then comparguments reads what is left, where `\` escapes again.
    #
    #   `[`  ->  `\[`      double quotes leave `\[` alone, comparguments reads `[`
    #   `$`  ->  `\$`      double quotes yield `$`, comparguments reads `$`
    #   `\`  ->  `\\\\`    double quotes yield `\\`, comparguments reads `\`
    #
    # A backslash escaped only twice reaches comparguments as a lone `\`, which
    # escapes whatever follows — a trailing one swallows the closing bracket and
    # the whole optspec is rejected.
    ZSH_OPTSPEC = {
      "\\" => "\\\\\\\\",
      '"'  => '\\"',
      "$"  => "\\$",
      "`"  => "\\`",
      "["  => "\\[",
      "]"  => "\\]",
    }.freeze

    ZSH_OPTSPEC_PATTERN = Regexp.union(ZSH_OPTSPEC.keys).freeze

    #
    # Escape a description for use inside a zsh `_arguments` optspec.
    # @param text [String] the description as written by the CLI author
    # @return [String] the same text, inert for zsh
    def self.zsh_optspec(text)
      text.to_s.gsub(ZSH_OPTSPEC_PATTERN, ZSH_OPTSPEC)
    end

    #
    # Escape a description for use inside a single-quoted zsh word, as used by
    # the `commands=( 'name:description' )` array. Nothing is live inside single
    # quotes, so only the quote itself needs handling: close, emit an escaped
    # quote, reopen.
    # @param text [String] the description as written by the CLI author
    # @return [String] the same text, inert for zsh
    def self.zsh_single_quoted(text)
      text.to_s.gsub("'", %q('"'"'))
    end

  end
end
