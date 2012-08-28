class Braai::Configuration

  attr_accessor :logger
  attr_accessor :raise_on_missing_handler
  attr_accessor :swallow_handler_errors
  attr_accessor :for_loop_regex
  attr_accessor :handler_regex

  def initialize
    self.raise_on_missing_handler = false
    self.swallow_handler_errors = true
    self.handler_regex = /{{\s*[^}]+\s*}}/i
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