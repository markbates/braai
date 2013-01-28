module Braai::Matchers

  def matchers
    @matchers ||= reset!
  end

  def map(regex, handler = nil, &block)
    @matchers = {regex.to_s => handler || block}.merge(self.matchers)
  end

  def unmap(regex)
    self.matchers.delete(regex.to_s)
  end

  def clear!
    self.matchers.clear
  end

  def reset!
    @matchers = {}
    set_defaults
  end

  def set_defaults
    map(/({{\s*for (\w+) in (\w+)\s*}}(.+?){{\s*\/for\s*}})/im, Braai::Handlers::IterationHandler)
    map(/({{\s*([\w\.]+)\s*}})/i, Braai::Handlers::DefaultHandler)
  end

end
