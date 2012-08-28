class Braai::Configuration

  attr_accessor :logger
  attr_accessor :raise_on_missing_handler
  attr_accessor :swallow_handler_errors

  def initialize
    self.raise_on_missing_handler = false
    self.swallow_handler_errors = true
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