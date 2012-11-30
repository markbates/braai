require 'bundler/setup'

require 'braai' # and any other gems you need

Braai.config.logger = Logger.new(StringIO.new)

RSpec.configure do |config|

  config.before do
    Braai::Template.reset!
  end

end