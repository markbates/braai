class Braai::Context

  attr_accessor :attributes
  attr_accessor :template
  attr_accessor :matchers

  def initialize(template, matchers, attributes = {})
    self.attributes = HashWithIndifferentAccess.new(attributes)
    self.template = template.dup
    self.matchers = matchers
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
    self.process_loops
    self.process_keys
    return self.template
  end

  protected
  def process_loops
    loops = self.template.scan(Braai.config.for_loop_regex)
    loops.each do |loop|
      res = []
      self.attributes[loop[2]].each do |val|
        res << Braai::Context.new(loop[3], self.matchers, self.attributes.merge(loop[1] => val)).render!
      end
      self.template.gsub!(loop[0], res.join("\n"))
    end
  end

  def process_keys
    keys = self.template.scan(Braai.config.matcher_regex).flatten.uniq
    keys.each do |key|
      self.handle_key(key)
    end
  end

  def handle_key(key)
    stripped_key = key.gsub(/({|})/, "").strip
    matched = false
    self.matchers.each do |regex, matcher|
      regex = Regexp.new(regex)
      if regex.match(stripped_key)
        begin
          val = matcher.call(self, stripped_key, stripped_key.scan(regex).flatten)
          self.template.gsub!(key, val.to_s) if val
        rescue Exception => e
          raise e unless Braai.config.swallow_matcher_errors
        end
        matched = true
        break
      end
    end
    raise Braai::MissingMatcherError.new(stripped_key) if !matched && Braai.config.raise_on_missing_matcher    
  end

end