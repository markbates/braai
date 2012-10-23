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
    @matchers = {
      /({{\s*for (\w+) in (\w+)\s*}}(.+?){{\s*\/for\s*}})/im => ->(template, key, matches) {
        res = []
        template.attributes[matches[2]].each do |val|
          res << Braai::Context.new(matches[3], template.matchers, template.attributes.merge(matches[1] => val)).render
        end
        res.join("\n")
      },
      /({{\s*([\w]+)\.([\w]+)\s*}})/i => ->(template, key, matches) {
        attr = template.attributes[matches[1]]
        attr ? attr.send(matches[2]) : nil
      },
      /({{\s*([\w]+)\s*}})/i => ->(template, key, matches) {
        attr = template.attributes[matches.last]
        attr ? attr.to_s : nil
      }
    }
    return @matchers
  end

end