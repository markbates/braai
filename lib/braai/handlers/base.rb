module Braai::Handlers
  class Base
    attr_accessor :template, :key, :matches

    def initialize(template, key, matches)
      @template = template
      @key = key
      @matches = matches
    end

    class << self

      attr_accessor :error_handler, :nomatch_handler

      def call(template, key, matches)
        handler = self.new(template, key, matches)
        handler.safe_perform
      end
    end

    def safe_perform
      value = begin
        perform
      rescue => e
        rescue_from_error(e)
      end

      if [key, nil].include?(value) && self.class.nomatch_handler
        value = self.class.nomatch_handler.call(key)
      end

      value
    end

    # override this method in your own handlers
    def perform
      key
    end

    def rescue_from_error(e)
      if self.class.error_handler
        self.class.error_handler.call(e)
      else
        key
      end
    end
  end
end
