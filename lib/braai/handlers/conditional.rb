module Braai::Handlers
  class Conditional < Base
    include Braai::Helpers

    def perform
      res = resolve_variable_chain_value(matches[1])
      if res && res != ""
        Braai::Context.new(matches[2], template, template.attributes).render
      else
        ""
      end
    end
  end
end
