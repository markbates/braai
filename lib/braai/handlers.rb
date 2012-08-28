module Braai::Handlers

  def handlers
    @handlers ||= reset!
  end

  def map(regex, &block)
    @handlers = {regex.to_s => block}.merge(self.handlers)
  end

  def unmap(regex)
    self.handlers.delete(regex.to_s)
  end

  def clear!
    self.handlers.clear
  end

  def reset!
    @handlers = {}
    return @handlers
  end

end