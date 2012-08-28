class Braai::Context

  attr_accessor :attributes
  attr_accessor :template
  attr_accessor :handlers

  def initialize(template, handlers, attributes = {})
    self.attributes = HashWithIndifferentAccess.new(attributes)
    self.template = template.dup
    self.handlers = handlers
  end

  def render
    begin
      self.render!
    rescue Exception => e
      Braai.logger.error(e)
      raise e
    end
  end

  def render!
    # {{\s*for (\w+) in (\w+).+\/for\s*}}
    keys = self.template.scan(Braai.config.handler_regex).flatten.uniq
    keys.each do |key|
      self.handle_key(key)
    end
    return self.template
  end

  protected
  def handle_key(key)
    stripped_key = key.gsub(/({|})/, "").strip
    matched = false
    self.handlers.each do |regex, handler|
      regex = Regexp.new(regex)
      if regex.match(stripped_key)
        begin
          val = handler.call(self, stripped_key, stripped_key.scan(regex).flatten)
          self.template.gsub!(key, val.to_s) if val
        rescue Exception => e
          raise e unless Braai.config.swallow_handler_errors
        end
        matched = true
        break
      end
    end
    raise Braai::MissingHandlerError.new(stripped_key) if !matched && Braai.config.raise_on_missing_handler    
  end

end