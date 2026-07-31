# frozen_string_literal: true

require "spec_helper"

RSpec.describe Fylla::Thor::CompletionGenerator do

  subject(:script) { zsh_script(Zsh::PlainSubcommands::Main) }

  it "generates the whole script for a nested application" do
    expected = <<~'SCRIPT'
      #compdef _test test
      function _test_help {
        _arguments \
          "-h[Show help information]" \
          "--help[Show help information]"
      }
      function _test_tree {
        _arguments \
          "-h[Show help information]" \
          "--help[Show help information]"
      }
      function _test_generate_completions {
        _arguments \
          "-h[Show help information]" \
          "--help[Show help information]"
      }
      function _test_sub_help {
        _arguments \
          "-h[Show help information]" \
          "--help[Show help information]"
      }
      function _test_sub_tree {
        _arguments \
          "-h[Show help information]" \
          "--help[Show help information]"
      }
      function _test_sub_generate_completions {
        _arguments \
          "-h[Show help information]" \
          "--help[Show help information]"
      }
      function _test_sub_noopts {
        _arguments \
          "-h[Show help information]" \
          "--help[Show help information]"
      }
      function _test_sub_withopts {
        _arguments \
          "--an_option=[AN_OPTION]" \
          "-h[Show help information]" \
          "--help[Show help information]"
      }
      function _test_sub {
        local line

        local -a commands
        commands=(
          'generate_completions:generate completions'
          'help:Describe subcommands or one specific subcommand'
          'noopts:subcommand that takes no options'
          'tree:Print a tree of all available commands'
          'withopts:subcommand that takes options'
        )

        _arguments \
          "-h[Show help information]" \
          "--help[Show help information]" \
          "1: : _describe 'command' commands" \
          "*::arg:->args"

        case $state in
          args)
            case $line[1] in
              generate_completions)
                _test_sub_generate_completions
              ;;
              help)
                _test_sub_help
              ;;
              noopts)
                _test_sub_noopts
              ;;
              tree)
                _test_sub_tree
              ;;
              withopts)
                _test_sub_withopts
              ;;
            esac
          ;;
        esac
      }
      function _test {
        local line

        local -a commands
        commands=(
          'generate_completions:generate completions'
          'help:Describe available commands or one specific command'
          'sub:a subcommand'
          'tree:Print a tree of all available commands'
        )

        _arguments \
          "-h[Show help information]" \
          "--help[Show help information]" \
          "1: : _describe 'command' commands" \
          "*::arg:->args"

        case $state in
          args)
            case $line[1] in
              generate_completions)
                _test_generate_completions
              ;;
              help)
                _test_help
              ;;
              sub)
                _test_sub
              ;;
              tree)
                _test_tree
              ;;
            esac
          ;;
        esac
      }
      _test "$@"
    SCRIPT

    expect(script).to eq expected
  end

  it "declares the compdef header zsh needs to pick the script up" do
    expect(script).to start_with("#compdef _test test\n")
  end

  it "defines a subcommand function before the parent that dispatches to it" do
    expect(script.index("function _test_sub {")).to be < script.index("function _test {")
  end

end
