module Braai::Handlers
  class Default < Base
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
