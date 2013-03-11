module Braai::Handlers
  class Default < Base
    include Braai::Helpers

    def perform
      resolve_variable_chain_value(matches[1])
    end
  end
end
