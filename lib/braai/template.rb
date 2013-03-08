class Braai::Template
  extend Braai::Matchers
  include Braai::Matchers

  attr_accessor :template

  def initialize(template, matchers = {})
    @matchers = self.class.matchers.merge(matchers)
    @template = template
    @fallback = self.class.fallback
  end

  def render(attributes = {})
    context = Braai::Context.new(@template, self, attributes)
    context.render
  end

end
