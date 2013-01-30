require 'spec_helper'
require 'ostruct'

describe Braai::Handlers::Base do
  include Mocha::Integration::MiniTest
  include Braai::Matchers

  let(:person)   { OpenStruct.new(name: "My Name", title: "Director") }
  let(:template) { "Hello {{ person.name }}" }
  let(:key)      { "{{ person.name }}" }
  let(:matches)  { [ "{{ person.name }}", "name" ] }
  let(:handler)  { Braai::Handlers::Base.new(template, key, matches) }

  describe '.call' do

    it 'condition' do
      Braai::Handlers::Base.any_instance.expects(:safe_perform)
      Braai::Handlers::Base.call(template, key, matches)
    end

  end

  describe '#initialize' do

    it 'creates an object with instance variables' do
      handler = Braai::Handlers::Base.new(template, key, matches)
      handler.template.must_equal(template)
      handler.key.must_equal(key)
      handler.matches.must_equal(matches)
    end
  end

  describe '#perform' do

    it 'returns the original template by default' do
      handler.perform.must_equal("Hello {{ person.name }}")
    end
  end

  describe '#safe_perform' do

    it 'calls perform on the handler' do
      handler.expects(:perform)
      handler.safe_perform
    end

    it 'should receive rescue_from_error when needed' do
      handler.stubs(:perform).raises(ArgumentError)
      handler.safe_perform.must_equal('Hello {{ person.name }}')
    end
  end

  describe '#rescue_from_error' do

    it 'call the class method of the same name' do
      handler.rescue_from_error(ArgumentError).must_equal('Hello {{ person.name }}')
    end
  end
end
