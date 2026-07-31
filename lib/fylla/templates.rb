# frozen_string_literal: true

require "erb"

module Fylla
  #
  # The four ERB templates, read and compiled once.
  #
  # They used to be re-read from disk and recompiled for every node of the
  # command tree, which for a large CLI meant one `File.read` and one ERB
  # compilation per command.
  module Templates

    ROOT = File.expand_path("erb_templates", __dir__)

    # Trim mode `-` enables `<%-` / `-%>`, `<>` and `>` drop the newline the
    # template tags would otherwise leave behind. The generated scripts are
    # compared byte for byte in the specs, so this is load bearing.
    TRIM_MODE = "-<>"

    @templates = {}

    class << self

      #
      # @param style [Symbol, String] target shell, +:zsh+ or +:bash+
      # @param name [Symbol, String] template kind, +:command+ or +:subcommand+
      # @return [ERB] the compiled template
      def fetch(style, name)
        key = "#{style}/#{name}"
        @templates[key] ||= ERB.new(File.read(path_for(key)), trim_mode: TRIM_MODE)
      end

      private

      def path_for(key)
        File.join(ROOT, "#{key}.erb")
      end

    end

  end
end
