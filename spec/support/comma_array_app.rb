# frozen_string_literal: true

require "thor"

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
