require 'spec_helper'

describe Braai::Handlers::Default do
  include Mocha::Integration::MiniTest
  include Braai::Matchers

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
