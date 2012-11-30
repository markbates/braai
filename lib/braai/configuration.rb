class Braai::Configuration

  attr_accessor :logger
  attr_accessor :swallow_matcher_errors

  def initialize
    self.swallow_matcher_errors = true
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