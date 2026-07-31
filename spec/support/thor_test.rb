# frozen_string_literal: true

require "thor"

module Zsh
  # Base class every zsh fixture inherits from. It carries the command the
  # examples invoke, which is why `generate_completions` shows up in almost
  # every expected script.
  class ThorTest < Thor
    include Thor::Base

    desc "generate_completions", "generate completions"
    def generate_completions
      puts Fylla.zsh_completion(self)
    end
  end
end
