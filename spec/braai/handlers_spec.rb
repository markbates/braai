require 'spec_helper'

describe Braai::Handlers do
  include Braai::Matchers

  describe "for loops" do

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

  describe "default matcher" do

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
