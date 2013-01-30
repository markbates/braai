require 'spec_helper'
require 'ostruct'

describe Braai::Handlers do
  include Mocha::Integration::MiniTest
  include Braai::Matchers

  describe Braai::Handlers::Base do
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

  describe Braai::Handlers::IterationHandler do

    let(:template) do
<<-EOF
<h1>{{ greet }}</h1>
<ul>
  {{ for product in products }}
    <li>{{ product }}</li>
  {{ /for }}
</ul>
<div>
  {{ for food in foods }}
    <p>{{ food }}</p>
  {{ /for }}
</div>
<h2>{{greet.upcase}}</h2>
EOF
    end

    it "renders the loop" do
      res = Braai::Template.new(template).render(greet: "mark", products: %w{car boat truck}, foods: %w{apple orange})
      res.must_match("<h1>mark</h1>")
      res.must_match("<li>car</li>")
      res.must_match("<li>boat</li>")
      res.must_match("<li>truck</li>")
      res.must_match("<p>apple</p>")
      res.must_match("<p>orange</p>")
      res.must_match("<h2>MARK</h2>")
    end

  end

  describe Braai::Handlers::DefaultHandler do

    let(:template) { "{{ greet }} {{ name.upcase }}" }
    let(:adv_template) { "{{ greet }} my name is {{ name.full_name.upcase }}" }

    it "uses the default matcher to render" do
      res = Braai::Template.new(template).render(greet: "Hi", name: "mark")
      res.must_equal("Hi MARK")
    end

    it "handles the attribute not being there" do
      res = Braai::Template.new(template).render(greet: "Hi")
      res.must_equal("Hi {{ name.upcase }}")
    end

    it "handles deeply nested attributes" do
      res = Braai::Template.new(adv_template).render(greet: "Hello", name: OpenStruct.new(full_name: 'inigo montoya'))
      res.must_equal("Hello my name is INIGO MONTOYA")
    end

    it "handles nested attribute hashes" do
      res = Braai::Template.new(adv_template).render(greet: "Hello", name: { full_name: 'inigo montoya' })
      res.must_equal("Hello my name is INIGO MONTOYA")
    end

  end
end
