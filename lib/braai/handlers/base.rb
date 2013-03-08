# Braai.rescue_from Exception, ->{}
# Braai.rescue_from ArgumentError, ->{}


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
      value = begin
        perform
      rescue => e
        rescue_from_error(e)
      end
      value
    end

    # override this method in your own handlers
    def perform
      key
    end

    def rescue_from_error(e)
      Braai::Handlers.rescuers.each do |rescuer|
        if e.is_a?(rescuer[:klass])
          return rescuer[:handler].call(self, e)
        end
      end
      raise e
    end
  end
end
