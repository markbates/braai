module Braai
  module Helpers
    def resolve_variable_chain_value(str)
      value = nil
      chain = str.split('.')

      if template.attributes.has_key?(chain.first)
        value = template.attributes[chain.shift] || ''
      else
        return nil unless value
      end

      chain.each do |a|
        if value.respond_to?(a.to_sym)
          value = value.send(a) || ''
        elsif value.is_a?(Hash)
          if value.has_key?(a.to_sym) || value.has_key?(a.to_s)
            value = value[a.to_sym] || value[a.to_s] || ''
          else
            return nil
          end
        else
          return nil
        end
      end

      value
    end
  end
end
