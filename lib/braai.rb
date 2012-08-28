require 'logger'
require "braai/version"
require "braai/configuration"
require "braai/errors"
require "braai/handlers"
require "braai/template"

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
