module Braai::Matchers

  IterationMatcher = /({{\s*for (\w+) in (\w+)\s*}}(.+?){{\s*\/for\s*}})/im
  DefaultMatcher = /({{\s*([\w\.]+)\s*}})/i

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
    map(IterationMatcher, Braai::Handlers::Iteration)
    map(DefaultMatcher, Braai::Handlers::Default)
  end

end
