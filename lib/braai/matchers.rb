module Braai::Matchers

  def matchers
    @matchers ||= reset!
  end

  def map(regex, &block)
    @matchers = {regex.to_s => block}.merge(self.matchers)
  end

  def unmap(regex)
    self.matchers.delete(regex.to_s)
  end

  def clear!
    self.matchers.clear
  end

  def reset!
    @matchers = {
      /^([\w]+)\.([\w]+)$/i => ->(template, key, matches) {
        attr = template.attributes[matches.first]
        attr ? attr.send(matches.last) : nil
      },
      /^(\w+)$/i => ->(template, key, matches) {
        attr = template.attributes[matches.first]
        attr ? attr.to_s : nil
      }
    }
    return @matchers
  end

end