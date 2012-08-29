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
      self.matchers.each do |regex, matcher|
        regex = Regexp.new(regex)
        matches = self.template.scan(regex)
        matches.each do |set|
          val = matcher.call(self, set[0], set)
          self.template.gsub!(set[0], val.to_s) if val
        end
      end
      return self.template
    rescue Exception => e
      puts e.inspect
      Braai.logger.error(e)
      raise e unless Braai.config.swallow_matcher_errors
    end
  end

end