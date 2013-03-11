require 'spec_helper'

describe Braai::Handlers::Conditional do
  include Mocha::Integration::MiniTest
  include Braai::Matchers

  let(:template) do
<<-EOF
<ul>
  {{ if product.active }}
    <li>
      <h1>{{ product.name }}</h1>
      {{ if product.description }}<h2>{{ product.description }}</h2>{{ /if }}
    </li>
  {{ /if }}
</ul>
EOF
  end

  let(:inactive_product) do
    OpenStruct.new(name: 'Inactive Thing', active: false, description: 'This is a thing.')
  end

  let(:active_product) do
    OpenStruct.new(name: 'Active Thing', active: true, description: 'This is a thing.')
  end

  let(:missing_attribute_product) do
    OpenStruct.new(name: 'No Description', active: true)
  end

  let(:empty_attribute_product) do
    OpenStruct.new(name: 'Empty Description', active: true, description: '')
  end

  it "does not render conditional items that fail the test" do
    res = Braai::Template.new(template).render(product: inactive_product)
    res.gsub(/\s+/, '').must_match("<ul></ul>")
  end

  it "renders conditional items that pass the test" do
    res = Braai::Template.new(template).render(product: active_product)
    res.must_match(/Active Thing/)
  end

  it "renders the conditional string if present" do
    res = Braai::Template.new(template).render(product: active_product)
    res.must_match(/This is a thing/)
  end

  it "does not render conditional string when the value is empty" do
    res = Braai::Template.new(template).render(product: empty_attribute_product)
    res.wont_match("h2")
  end

  it "does not render conditional string when the attribute is missing" do
    res = Braai::Template.new(template).render(product: missing_attribute_product)
    res.wont_match("h2")
  end
end
