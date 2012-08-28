class Braai::Template
  extend Braai::Handlers
  include Braai::Handlers

  attr_accessor :attributes
  attr_accessor :template

  def initialize(template, handlers = {})
    self.template = template
    @handlers = self.class.handlers.merge(handlers)
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
    context = Braai::Context.new(self.template, self.handlers, attributes)
    context.render!
  end

end