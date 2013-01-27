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
    @matchers ||= {}

    @matchers[/({{\s*for (\w+) in (\w+)\s*}}(.+?){{\s*\/for\s*}})/im] = ->(template, key, matches) {
      res = []
      template.attributes[matches[2]].each do |val|
        res << Braai::Context.new(matches[3], template.matchers, template.attributes.merge(matches[1] => val)).render
      end
      res.join("\n")
    }

    @matchers[/({{\s*([\w\.]+)\s*}})/i] = ->(template, key, matches) {
      chain = matches[1].split('.')
      value = template.attributes[chain.shift]
      return nil unless value

      chain.each do |a|
        if value.respond_to?(a.to_sym)
          value = value.send(a)
        elsif value.is_a?(Hash)
          value = value[a.to_sym] || value[a.to_s]
        else
          return nil
        end
      end

      value
    }

    @matchers[/({{\s*([\w]+)\s*}})/i] = ->(template, key, matches) {
      attr = template.attributes[matches.last]
      attr ? attr.to_s : nil
    }

    @matchers
  end

end
