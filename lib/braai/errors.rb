module Braai
  class MissingMatcherError < StandardError
    def initialize(key)
      super "#{key} was missing a matcher! Please implement one."
    end
  end
end