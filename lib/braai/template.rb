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
      results = self.render!(attributes)
      return results
    rescue Exception => e
      Braai.logger.error(e)
      raise e
    end
  end

  def render!(attributes)
    self.attributes = HashWithIndifferentAccess.new(attributes)
    results = self.template.dup
    # {{\s*for (\w+) in (\w+).+\/for\s*}}
    keys = self.template.scan(Braai.config.handler_regex).flatten.uniq
    keys.each do |key|
      stripped_key = key.gsub(/({|})/, "").strip
      matched = false
      self.handlers.each do |regex, handler|
        regex = Regexp.new(regex)
        if regex.match(stripped_key)
          begin
            val = handler.call(self, stripped_key, stripped_key.scan(regex).flatten)
            results.gsub!(key, val.to_s) if val
          rescue Exception => e
            raise e unless Braai.config.swallow_handler_errors
          end
          matched = true
          break
        end
      end
      raise Braai::MissingHandlerError.new(stripped_key) if !matched && Braai.config.raise_on_missing_handler
    end
    
    return results
  end

end