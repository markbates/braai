require 'logger'
require "active_support/core_ext/hash/indifferent_access"
require "braai/version"
require "braai/configuration"
require "braai/helpers"
require "braai/handlers"
require "braai/matchers"
require "braai/template"
require "braai/context"

module Braai

  class << self

    def config
      @config ||= Braai::Configuration.new
      yield @config if block_given?
      return @config
    end

    def logger
      self.config.logger
    end

  end

end
