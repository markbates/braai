require 'braai/handlers/base'
require 'braai/handlers/default'
require 'braai/handlers/iteration'
require 'braai/handlers/conditional'

module Braai
  module Handlers

    class << self
      def rescue_from(klass, handler)
        self.rescuers.unshift({klass: klass, handler: handler})
      end

      def rescuers
        @rescuers ||= []
      end
    end

  end
end
