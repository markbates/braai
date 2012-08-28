module Braai
  class MissingHandlerError < StandardError
    def initialize(key)
      super "#{key} was missing a handler! Please implement one."
    end
  end
end