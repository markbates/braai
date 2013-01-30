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

  class IterationHandler < Base
    def perform
      res = []
      template.attributes[matches[2]].each do |val|
        res << Braai::Context.new(matches[3], template.matchers, template.attributes.merge(matches[1] => val)).render
      end
      res.join("\n")
    end
  end

  class DefaultHandler < Base
    def perform
      chain = matches[1].split('.')
      value = template.attributes[chain.shift]
      return nil unless value

      chain.each do |a|
        if value.respond_to?(a.to_sym)
          value = value.send(a)
        elsif value.is_a?(Hash)
          value = value[a.to_sym] || value[a.to_s]
        else
          return nil
        end
      end

      value
    end
  end

end
