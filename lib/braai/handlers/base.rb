module Braai::Handlers
  class Base
    attr_accessor :template, :key, :matches

    def initialize(template, key, matches)
      @template = template
      @key = key
      @matches = matches
    end

    class << self

      def call(template, key, matches)
        handler = self.new(template, key, matches)
        handler.safe_perform
      end

    end

    def safe_perform
      begin
        perform
      rescue => e
        rescue_from_error(e)
      end
    end

    def perform
      template
    end

    def rescue_from_error(e)
      template
    end
  end
end
