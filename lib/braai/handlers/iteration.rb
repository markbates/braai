module Braai::Handlers
  class Iteration < Base
    def perform
      res = []
      template.attributes[matches[2]].each do |val|
        res << Braai::Context.new(matches[3], template, template.attributes.merge(matches[1] => val)).render
      end
      res.join("\n")
    end
  end
end
