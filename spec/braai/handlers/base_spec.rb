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

  before do
    Braai::Handlers.rescuers.clear
  end

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

    it 'returns the key by default (should be overridden in implementations)' do
      handler.perform.must_equal("{{ person.name }}")
    end
  end

  describe '#safe_perform' do

    it 'calls perform on the handler' do
      handler.expects(:perform)
      handler.safe_perform
    end

    it 'rescues from error when needed' do
      handler.stubs(:perform).raises(ArgumentError)
      handler.expects(:rescue_from_error).returns('<!-- foo -->')
      handler.safe_perform.must_equal('<!-- foo -->')
    end

  end

  describe '#rescue_from_error' do

    it 'calls a user-defined error handler if specified' do
      Braai::Handlers.rescue_from ArgumentError, ->(handler, e) { "<!-- #{key} -->" }
      handler.rescue_from_error(ArgumentError.new).must_equal('<!-- {{ person.name }} -->')
    end

    it "raises the error if there is not rescuer" do
      ->{
        handler.rescue_from_error(ArgumentError.new)
      }.must_raise(ArgumentError)
    end

    it "stops after the first matching rescuer" do
      Braai::Handlers.rescue_from Exception, ->(handler, e) { "!!! #{key} !!!" }
      Braai::Handlers.rescue_from ArgumentError, ->(handler, e) { "<!-- #{key} -->" }
      handler.rescue_from_error(ArgumentError.new).must_equal('<!-- {{ person.name }} -->')
    end

  end

  describe 'default template rendering' do

    it 'performs no substitution' do
      Braai::Template.clear!
      Braai::Template.map(Braai::Matchers::DefaultMatcher, Braai::Handlers::Base)
      res = Braai::Template.new("{{ greet }} my name is {{ name }}").render(greet: "Hello")
      res.must_equal("{{ greet }} my name is {{ name }}")
    end
  end
end
