class Braai::Configuration

  attr_accessor :logger
  attr_accessor :raise_on_missing_matcher
  attr_accessor :swallow_matcher_errors
  attr_accessor :for_loop_regex
  attr_accessor :matcher_regex

  def initialize
    self.raise_on_missing_matcher = false
    self.swallow_matcher_errors = true
    self.matcher_regex = /{{\s*[^}]+\s*}}/i
    self.for_loop_regex = /({{\s*for (\w+) in (\w+)\s*}}(.+?){{\s*\/for\s*}})/im
  end

  def logger
    @logger ||= begin
      if defined?(Rails)
        Rails.logger
      else
        Logger.new(STDOUT)
      end
    end
  end

end