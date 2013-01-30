require 'bundler/setup'

require 'braai' # and any other gems you need

require 'minitest/autorun'
require 'minitest-colorize'
require 'mocha'

Braai.config.logger = Logger.new(StringIO.new)

class MiniTest::Spec

  before do
    Braai::Template.reset!
  end

end
