module Braai::Matchers

  attr_accessor :fallback

  IterationMatcher   = /({{\s*for (\w+) in (\w+)\s*}}(.+?){{\s*\/for\s*}})/im
  ConditionalMatcher = /({{\s*if\s*([\w\.]+)\s*}}(.*){{\s*\/if\s*}})/mi
  DefaultMatcher     = /({{\s*([\w\.]+)\s*}})/i
  RegionMatcher      = /({{\s*([\w]+)\s*}}(.*){{\s*\/([\w]+)\s*}})/mi

  def matchers
    @matchers ||= reset!
  end

  def map(regex, handler = nil, &block)
    @matchers = {regex.to_s => handler || block}.merge(self.matchers)
  end

  def add_fallback(regex, handler=nil, &block)
    @fallback = { :regex => regex.to_s, :handler => handler || block }
  end

  def unmap(regex)
    self.matchers.delete(regex.to_s)
  end

  def clear!
    self.matchers.clear
    self.fallback = nil
  end

  def reset!
    @matchers = {}
    set_defaults
  end

  def set_defaults
    map(IterationMatcher, Braai::Handlers::Iteration)
    map(ConditionalMatcher, Braai::Handlers::Conditional)
    map(DefaultMatcher, Braai::Handlers::Default)
  end

end
