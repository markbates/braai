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
    @handlers = {
      /^([\w]+)\.([\w]+)$/i => ->(template, key, matches) {
        attr = template.attributes[matches.first]
        attr ? attr.send(matches.last) : nil
      },
      /^(\w+)$/i => ->(template, key, matches) {
        attr = template.attributes[matches.first]
        attr ? attr.to_s : nil
      }
    }
    return @handlers
  end

end