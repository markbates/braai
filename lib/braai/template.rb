class Braai::Template
  extend Braai::Matchers
  include Braai::Matchers

  attr_accessor :attributes
  attr_accessor :template

  def initialize(template, matchers = {})
    self.template = template
    @matchers = self.class.matchers.merge(matchers)
  end

  def render(attributes = {})
    begin
      return self.render!(attributes)
    rescue Exception => e
      Braai.logger.error(e)
      raise e
    end
  end

  def render!(attributes)
    context = Braai::Context.new(self.template, self.matchers, attributes)
    context.render!
  end

end